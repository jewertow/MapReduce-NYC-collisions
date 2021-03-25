package com.github.jewertow

import org.apache.hadoop.conf.Configured
import org.apache.hadoop.fs.Path
import org.apache.hadoop.io.{IntWritable, Text}
import org.apache.hadoop.mapreduce.Job
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat
import org.apache.hadoop.util.{Tool, ToolRunner}


object CollisionsJob extends Configured with Tool {

  def main(args: Array[String]): Unit = {
    val res = ToolRunner.run(CollisionsJob, args)
    System.exit(res)
  }

  override def run(args: Array[_root_.java.lang.String]): Int = {
    val job = Job.getInstance(getConf, "collisions")
    job.setJarByClass(this.getClass)
    FileInputFormat.addInputPath(job, new Path(args(0)))
    FileOutputFormat.setOutputPath(job, new Path(args(1)))
    job.setMapperClass(classOf[CollisionsMapper])
    job.setReducerClass(classOf[CollisionsReducer])
    job.setOutputKeyClass(classOf[Text])
    job.setOutputValueClass(classOf[IntWritable])
    if (job.waitForCompletion(true)) 0 else 1
  }
}
