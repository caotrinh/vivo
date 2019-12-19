export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export CLASSPATH="/usr/local/vivo/home/shindig/conf"

### CONFIG: JMX MONITORING DISABLED
export CATALINA_OPTS="-Xms512m -Xmx4096m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/usr/local/software -Dshindig.host=scholars.uow.edu.au -Dshindig.port=443"

### CONFIG: JMX MONITORING ENABLED
# export CATALINA_OPTS="-Xms512m -Xmx4096m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/usr/local/software -Dshindig.host=scholars.uow.edu.au -Dshindig.port=443 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.password.file=/usr/local/java/jdk1.8.0_121/jre/lib/management/jmxremote.password -Dcom.sun.management.jmxremote.port=9099"