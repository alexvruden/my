# Стратегии<br>

Файлы стратегии помещаются в отдельные директории.<br>
Описание старатегии пишем в 'about'.<br>
Файл стратегии должен быть с расширением '.strategy'<br>
Остальные расширения игнорируются скриптом.<br>
<br>
Пример файла стратегии:<br>
<br>
Первая строка игнорируется скриптом, здесь можно написать пометки для себя <br>
Строки, начинающиеся с символа # игнорируются - пометки для себя<br>
Если строка начинается с двух символов ##, то скрипт обработает ее и добавит к описанию ПРОФИЛЯ стратегии, не путать с 'about'.<br>
Если символы ## для описания профиля отсутствуют, то описание будет создано из имени 'windivert' фильтра <br>

Далее указываем 'windivert' фильтр:<br>
<code>--wf-tcp=80</code><br>
<br>
Далее для winws:<br>
<br>
<code>HOSTLIST_NOAUTO</code> - этот маркер укажет скрипту включить аргумент <code>--hostlist</code> со всеми списками из директории 'hostlist'<br>
<code>HOSTLIST</code> - этот маркер укажет скрипту включить аргумент <code>--hostlist</code> и <code>--hostlist-auto</code> со всеми списками из директории 'hostlist'<br>
<code>IPSET</code> - этот маркер укажет скрипту включить аргумент <code>--ipset</code> со всеми списками из директории 'ipset'<br>
<br>
Можно писать в стратегии без маркера:<br>
<code>--hostlist=</code> - укажет скрипту включить аргумент <code>--hostlist</code> со всеми списками из директории 'hostlist' (с расширениями .txt, .lst, .gz)<br>
<code>--hostlist=host.txt</code> - укажет скрипту включить аргумент <code>--hostlist</code> с одним списком из директории 'hostlist'<br>
<code>--hostlist-auto=</code> - скрипт сам назначит файл 'hostlist-auto.txt' из директории 'hostlist'<br>
<code>--hostlist-auto=my_auto_file.txt</code> - пользователь указал имя файла (если такого файла нет в директории 'hostlist' , то он его создаст)<br>
<br>
Аналогично и с параметром <code>--ipset</code>
<code>--ipset=</code> - укажет скрипту включить аргумент <code>--ipset</code> со всеми списками из директории 'ipset' (с расширениями .txt, .lst, .gz)<br>
<code>--ipset=ip.txt</code> - укажет скрипту включить аргумент <code>--ipset</code> с одним списком из директории 'ipset'<br>
<br>
<code>--dpi-desync-fake-quic=quic_initial_www_google_com.bin</code> - пишем имя файла 'quic_initial_www_google_com.bin' без указания пути, скрипт знает, где он должен лежать, если файла нет, то он предупредит.<br>
<br>
Параметры <code>--hostlist-exclude</code> и <code>--ipset-exclude</code> автоматически добавляются ко всем профилям, по умолчанию используется стандартный 'zapret-hosts-user-exclude.txt.default', свои списки исключений можно создать в директории 'lists\exclude'<br>
<br>
------------------------------------------------------------------------------<br>
'\my\strategy\test\2.strategy'<br>

<code>
#blabla

##tcp: 443
--wf-tcp=443

##rule 1: hostlist

HOSTLIST_NOAUTO
--dpi-desync=split2
--dpi-desync-repeats=2
--dpi-desync-split-seqovl=681
--dpi-desync-split-pos=1
--dpi-desync-fooling=badseq,hopbyhop2
--dpi-desync-split-seqovl-pattern=tls_clienthello_www_google_com.bin

--new

##rule 2: ipset

IPSET
--dpi-desync=split2
--dpi-desync-split-seqovl=681
--dpi-desync-split-pos=1
--dpi-desync-fooling=badseq,hopbyhop2
--dpi-desync-split-seqovl-pattern=tls_clienthello_www_google_com.bin

# rule 0
</code>