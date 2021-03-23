scalaVersion     := "2.12.1"
version          := "0.1"
organization     := "com.github.jewertow"
name             := "mapreduce"

assemblyJarName in assembly := "collisions-mapreduce-job.jar"
assemblyMergeStrategy in assembly := {
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case PathList("reference.conf") => MergeStrategy.concat
  case _ => MergeStrategy.first
}

libraryDependencies ++= {
  val hadoopVersion = "2.10.1"
  Seq(
    "org.apache.hadoop" % "hadoop-common"                % hadoopVersion,
    "org.apache.hadoop" % "hadoop-mapreduce-client-core" % hadoopVersion,
    "org.scalatest"     %% "scalatest"                   % "3.0.0"        % Test,
    "org.mockito"       % "mockito-core"                 % "2.8.47"       % Test
  )
}
