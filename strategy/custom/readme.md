# Применение wf-raw<br>
<br>
Нельзя создать два процесса стратегии с фильтром <code>--wf-tcp</code> ( <code>--wf-udp</code> ) на одном порте, поэтому применим <code>--wf-raw</code>  и '<i>iptables</i>' в '<i>windivert</i>'.
<br>
Используя <code>--wf-raw</code> мы можем в ядре '<i>windivert</i>' на одном порте, но в разных процессах отсеивать трафик.
<br>
<br>
Strategy 1 ------------------------------------------------------------------------------<br>
<br>

<code>#test strategy 1</code>
<br>
<br>
<code>$tcp: 443 RAW iprange1</code> - скрипт прочтет строку и запомнит как описание этой стратегии
<br>
<code>--wf-tcp=@raw_tcp443_iprange1.txt</code>
<br>
<br>
<code>$rule 1: iprange1</code> - скрипт прочтет строку и добавит к предыдущуму описанию
<br>
<code>
TAMPER
</code>
<br>
<code>#--blabla</code> - закоменировали, скрипт проигнорирует строку
<br>
<br>
Strategy 2 ------------------------------------------------------------------------------<br>
<br>
<code>#test strategy 2</code>
<br>
<br>
<code>$tcp: 443 RAW iprange2</code> - скрипт прочтет строку и запомнит как описание этой стратегии
<br>
<code>--wf-tcp=@raw_tcp443_iprange2.txt</code>
<br>
<br>
<code>$rule 1: iprange2</code> - скрипт прочтет строку и добавит к предыдущуму описанию
<br>
<code>
TAMPER
</code>
<br>
<br>
После запуска будет создано два процесса '<i>winws</i>' со своими профилями на одном порту 443.
<br>
<br>
Пример разделения трафика с порта 443 на два дебаг-окна в папке cloudflare-raw.
