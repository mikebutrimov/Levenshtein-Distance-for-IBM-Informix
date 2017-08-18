# Levenshtein-Distance-for-IBM-Informix
Edit distance  function (based on Levenshtein distance) for  IBM Informix Server. 

in levenshtein.sql:

 - levenshtein()  - returns integer which is Levenshtein edit distance between two strings.

 - hexstr_to_bigint() and hexval() are taken from this StackOverflow question - https://stackoverflow.com/questions/31295620/how-to-process-bitand-operation-in-informix-with-column-in-hex-string-format



In java section:

 - ls_dst.java - java source code for Levenshtein distance (https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Java)
 
 
 how to set it up in Informix IDS:


1. Determine which version of java your IDS uses:

  - look at your JVPHOME var.
  - do JVPHOME/bin/java -version
  
2. Compile udr for your informix java version. For example like this: 
```
javac -target 1.6 -source 1.6 -bootclasspath /path to jre/jre1.6.0_45/lib/rt.jar ls_dst.java
```
3. Create jar from it:
```
jar cf ls_dst.jar ls_dst.class
```
4. Copy it to directory where informix has read-write rights
5. Execute statments:
```sql
EXECUTE PROCEDURE
  sqlj.install_jar("file://path to jar/ls_dst.jar", "lsdst_jar");
  ```
  here:
   - ls_dst.jar - your jar
   - lsdst_jar - name of the jar, which will be used by informix
   
  
 6. Create function:
 ```sql
 create function ls_dst(CHAR(50), CHAR(50))
returns integer
external name 'YOUR_DATABASE_NAME.YOUR_USER_NAME.lsdst_jar:ls_dst.ls_dst()'
language java;
```
Be careful in this part. It take a lot of time for me to figure out how i must set parameters.
if you have database named "testdb" with user "dummy" on it, your call will be:

```sql
create function ls_dst(CHAR(50), CHAR(50))
returns integer
external name 'testdb.dummy.lsdst_jar:ls_dst.ls_dst()'
language java;
```
```lsdst_jar``` in this path is jar name used in a call above
and ```ls_dst.ls_dst()``` - is a call of ```ls_dst``` function in ```ls_dst``` class (see java code)


Now you can use it like:
```sql
select ls_dst("smy", "Smyth") from some_table;
```
