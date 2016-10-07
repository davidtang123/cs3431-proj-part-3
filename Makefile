all : p3.class

clean :
	rm -rfv p3.class

p3.class : p3.java
	. /usr/local/bin/oraenv
	CLASSPATH=./:/usr/local/oracle11gr203/product/11.2.0/db_1/jdbc/lib/ojdbc6.jar javac p3.java
