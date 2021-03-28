package com.github.jewertow

import org.apache.avro.generic.GenericRecord
import org.apache.avro.mapreduce.{AvroJob, AvroKeyOutputFormat}
import org.apache.hadoop.conf.{Configuration, Configured}
import org.apache.hadoop.fs.Path
import org.apache.hadoop.io.{IntWritable, Text}
import org.apache.hadoop.mapreduce.Job
import org.apache.hadoop.mapreduce.lib.input.{FileInputFormat, TextInputFormat}
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat
import org.apache.hadoop.util.{Tool, ToolRunner}


object CollisionsJob extends Configured with Tool {

  def main(args: Array[String]): Unit = {
    val res = ToolRunner.run(CollisionsJob, args)
    System.exit(res)
  }

  override def run(args: Array[_root_.java.lang.String]): Int = {
    val conf = new Configuration()
    conf.set("mapreduce.output.textoutputformat.separator", ",")
    val job = Job.getInstance(conf, "collisions")
    job.setJarByClass(this.getClass)
    FileInputFormat.addInputPath(job, new Path(args(0)))
    FileOutputFormat.setOutputPath(job, new Path(args(1)))
    job.setMapperClass(classOf[CollisionsMapper])
    job.setCombinerClass(classOf[CollisionsCombiner])
    job.setReducerClass(classOf[CollisionsReducer])
    AvroJob.setOutputKeySchema(job, CollisionsReducer.CollisionsSchema)
    job.setMapOutputKeyClass(classOf[Text])
    job.setMapOutputValueClass(classOf[IntWritable])
    job.setInputFormatClass(classOf[TextInputFormat])
    job.setOutputFormatClass(classOf[AvroKeyOutputFormat[GenericRecord]])
    if (job.waitForCompletion(true)) 0 else 1
  }
}
