# ==============================================================
# Script : backup-dude
# RouterOS: v7.x
# =================================================================

# -------- CONFIGURAÇÕES -----------------------------------------
:local retention 30
:local prefix    "dude_backup_"

:local ftpUpload false          ;# true = envia ao FTP
:local ftpServer "192.0.2.10"
:local ftpUser   "ftpuser"
:local ftpPass   "ftppass"
:local ftpPath   "/"

# -------- DATA / HORA -------------------------------------------
:local rawDate [/system clock get date]   ;# ex: 2025-11-04  ou  nov/04/2025
:local rawTime [/system clock get time]   ;# ex: 10:38:59

:local day ""; :local month ""; :local year ""

# --- FORMATO ISO (YYYY-MM-DD) -----------------------------------
:if ([:find $rawDate "-"] != nil) do={
    :set year  [:pick $rawDate 0 4]
    :set month [:pick $rawDate 5 7]
    :set day   [:pick $rawDate 8 10]
} else={
# --- FORMATO COM “/” --------------------------------------------
    :local s1 [:find $rawDate "/"]
    :local p1 [:pick $rawDate 0 $s1]
    :local rest [:pick $rawDate ($s1+1) [:len $rawDate]]
    :local s2 [:find $rest "/"]
    :local p2 [:pick $rest 0 $s2]
    :local p3 [:pick $rest ($s2+1) [:len $rest]]

    # ano = parte com 4 dígitos
    :foreach p in=($p1,$p2,$p3) do={
        :if ([:len $p] = 4) do={ :set year $p }
    }

    # demais partes: uma é dia, outra é mês
    :foreach p in=($p1,$p2,$p3) do={
        :if ($p != $year) do={
            :if ([:len $p] > 2) do={ :set month $p } else={ :set day $p }
        }
    }

    # converte mês texto → número
    :local mLC [:tolower $month]
    :if ($mLC="jan") do={ :set month "01" }
    :if ($mLC="feb") do={ :set month "02" }
    :if ($mLC="mar") do={ :set month "03" }
    :if ($mLC="apr") do={ :set month "04" }
    :if ($mLC="may") do={ :set month "05" }
    :if ($mLC="jun") do={ :set month "06" }
    :if ($mLC="jul") do={ :set month "07" }
    :if ($mLC="aug") do={ :set month "08" }
    :if ($mLC="sep") do={ :set month "09" }
    :if ($mLC="oct") do={ :set month "10" }
    :if ($mLC="nov") do={ :set month "11" }
    :if ($mLC="dec") do={ :set month "12" }
}

# zero-fill
:if ([:len $day]   = 1) do={ :set day ("0".$day) }
:if ([:len $month] = 1) do={ :set month ("0".$month) }

# hora / minuto
:local hour [:pick $rawTime 0 2]
:local mins [:pick $rawTime 3 5]

# -------- NOME FINAL --------------------------------------------
:local fname ($prefix.$day."-".$month."-".$year."_".$hour.$mins)
:log info ("[DudeBackup] Criando: ".$fname)

# -------- BACKUP DO DUDE ----------------------------------------
/dude export-db backup-file=$fname

# -------- UPLOAD FTP (opcional) ---------------------------------
:if ($ftpUpload = true) do={
    :log info "[DudeBackup] Enviando ao FTP..."
    /tool fetch address=$ftpServer user=$ftpUser password=$ftpPass \
        src-path=$fname dst-path=($ftpPath.$fname) \
        upload=yes mode=ftp
    :log info "[DudeBackup] Upload concluído"
}

# -------- LIMPEZA ANTIGOS ---------------------------------------
:if ($retention > 0) do={
    :local files [/file find where name~("^".$prefix) sort-by=creation-time]
    :local total [:len $files]
    :if ($total > $retention) do={
        :for i from=0 to=($total-$retention-1) do={
            :local f [:pick $files $i]
            :log warning ("[DudeBackup] Removendo: ". [/file get $f name])
            /file remove $f
        }
    }
}

:log info "[DudeBackup] Finalizado OK"
