# Стратегии
<br>
<br>
Файлы стратегии помещаются в отдельные директории.
<br>
Описание старатегии пишем в '<i>about</i>'.
<br>
Файл стратегии должен быть с расширением '<i>.strategy</i>'
<br>
Остальные расширения игнорируются скриптом - можно задать другое расширение для отключения стратегии (аналог <code>--skip</code>)
<br>
Директория '<i>custom</i>' используется при триггере '<b>Запуск custom стратегий: да</b>'. Остальные директории игнорируются.
<br>
<br>
Пример файла стратегии:
<br>
<br>
Первая строка игнорируется скриптом, здесь можно написать пометки для себя
<br>
Строки, начинающиеся с символа <b>#</b> игнорируются - пометки для себя
<br>
Если строка начинается с символа <b>$</b>, то скрипт обработает ее и добавит к описанию ПРОФИЛЯ стратегии, не путать с '<i>about</i>'.
<br>
Если символ <b>$</b> для описания профиля отсутствует, то описание будет создано из имени '<i>windivert</i>' фильтра
<br>
<br>
'WINDIVERT FILTER':
<br>
<br>
<code>--wf-tcp=45</code>
<br>
<code>--wf-udp=123</code>
<br>
<code>--wf-raw=@file.ext</code> - пишем имя файла без указания пути, файл должен лежать в той же директории, где расположен файл стратегии
<br>
<br>
'MULTI-STRATEGY':
<br>
<br>
Можно указать
<br>
<code>--filter-tcp=<порт></code>
<br>
<code>--filter-udp=<порт></code>
<br>
<br>
'HOSTLIST FILTER':
<br>
<br>
<code>HOSTLIST_NOAUTO</code> - этот маркер укажет скрипту включить аргумент <code>--hostlist</code> со всеми списками из директории '<i>hostlist</i>' (с расширениями <b>.txt</b>, <b>.lst</b>, <b>.gz</b>)
<br>
<code>HOSTLIST</code> - этот маркер укажет скрипту включить аргумент <code>--hostlist</code> со всеми списками из директории '<i>hostlist</i>' и <code>--hostlist-auto</code> - скрипт сам назначит файл '<i>hostlist-auto.txt</i>' из директории '<i>hostlist</i>'
<br>
<code>IPSET</code> - этот маркер укажет скрипту включить аргумент <code>--ipset</code> со всеми списками из директории '<i>ipset</i>'
<br>
<br>
Можно писать в стратегии без маркера:
<br>
<code>--hostlist=</code> - укажет скрипту включить аргумент <code>--hostlist</code> со всеми списками из директории '<i>hostlist</i>' (с расширениями <b>.txt</b>, <b>.lst</b>, <b>.gz</b>)
<br>
<code>--hostlist=host.txt</code> - укажет скрипту включить аргумент <code>--hostlist</code> с одним списком (host.txt) из директории '<i>hostlist</i>'
<br>
<code>--hostlist=youtube\yt.txt</code> - укажет скрипту включить аргумент <code>--hostlist</code> с одним списком (yt.txt) из директории '<i>hostlist\youtube\</i>'
<br>
<code>--hostlist-auto=</code> - скрипт сам назначит файл '<i>hostlist-auto.txt</i>' из директории '<i>hostlist</i>'
<br>
<code>--hostlist-auto=my_auto_file.txt</code> - пользователь указал имя файла (если такого файла нет в директории '<i>hostlist</i>' , то он его создаст)
<br>
<br>
Аналогично и с параметром <code>--ipset</code>:
<br>
<code>--ipset=</code> - укажет скрипту включить аргумент <code>--ipset</code> со всеми списками из директории '<i>ipset</i>' (с расширениями <b>.txt</b>, <b>.lst</b>, <b>.gz</b>)
<br>
<code>--ipset=ip.txt</code> - укажет скрипту включить аргумент <code>--ipset</code> с одним списком (ip.txt) из директории '<i>ipset</i>'
<br>
<code>--ipset=user\ip.txt</code> - укажет скрипту включить аргумент <code>--ipset</code> с одним списком (ip.txt) из директории '<i>ipset\user\</i>'
<br>
<br>
'TAMPER':
<br>
<br> Для параметров с именами файлов неважен прописанный путь к файлу
<br>
Так напишете
<br>
<code>--dpi-desync-fake-quic=/p/a/t/c/h/dir/folder/quic_initial_www_google_com.bin</code>
<br>
или так
<br>
<code>--dpi-desync-fake-quic=c:\новая папка\dir\folder\quic_initial_www_google_com.bin</code>
<br>
или так
<br>
<code>--dpi-desync-fake-quic=quic_initial_www_google_com.bin</code>
<br>
скрипт выделит имя файла '<i>quic_initial_www_google_com.bin</i>' ,и знает, где он должен лежать, если файла нет, то он предупредит.
<br>
<br>
Если в качестве параметра указать <code>create:tls12,sni=rnd</code>, то скрипт сгенерирует hex-строку handshake tls v1.2 с рандомным sni (из имеющегося списка)
<br>
Если в качестве параметра указать <code>create:tls12,sni=www.domain.com</code>, то скрипт сгенерирует hex-строку handshake tls v1.2 с указанным sni
<br>
По-умолчанию используется <code>sni=www.google.com</code> (handshake без server_name работает, но не на всех доменах)
<br>
Например:
<br>
<code>--dpi-desync-split-seqovl-pattern=create:tls12</code> - сгенерирует строку handshake tls v1.2, sni=www.google.com
<br>
<code>--dpi-desync-split-seqovl-pattern=0x160303...</code> - handshake
<br>
<br>
Параметры <code>--hostlist-exclude</code> и <code>--ipset-exclude</code> автоматически добавляются ко всем профилям (если файл списка есть), их можно создать в директории '<i>lists\exclude</i>'
<br>
<br>
------------------------------------------------------------------------------
<br>
<br>

<code>#test strategy</code>
<br>
<br>
<code>$tcp: 443</code> - скрипт прочтет строку и запомнит как описание этой стратегии
<br>
<code>--wf-tcp=443</code>
<br>
<br>
<code>$rule 1: hostlist</code> - скрипт прочтет строку и добавит к предыдущуму описанию
<br>
<br>
<code>HOSTLIST_NOAUTO</code> - добавит все хостлисты
<br>
<code>--dpi-desync=split2
--dpi-desync-repeats=4
--dpi-desync-split-pos=1
--dpi-desync-fooling=badseq
--dpi-desync-split-seqovl-pattern=create:tls12
--dpi-desync-split-seqovl=calc</code>
<br>
<code>#--dpi-desync-split-seqovl-pattern=blabla</code> - закоменировали, скрипт проигнорирует строку
<br>
<br>
<code>--new</code>
<br>
<br>
<code>$rule 2: ipset</code> - скрипт прочтет строку и добавит к предыдущуму описанию
<br>
<br>
<code>IPSET
--dpi-desync=split2
--dpi-desync-split-seqovl=681
--dpi-desync-split-pos=1
--dpi-desync-fooling=badseq
--dpi-desync-split-seqovl-pattern=tls_clienthello_www_google_com.bin</code>
<br>
