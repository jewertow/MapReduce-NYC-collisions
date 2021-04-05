package com.github.jewertow

import java.lang

import com.github.jewertow.HadoopExt._
import org.apache.hadoop.io.{IntWritable, Text}
import org.apache.hadoop.mapreduce.Reducer

import scala.collection.JavaConverters._

class CollisionsCombiner extends Reducer[Text, IntWritable, Text, IntWritable] {

   override def reduce(key: Text, values: lang.Iterable[IntWritable], context: CombinerContext): Unit = {
     val sum = values.asScala.map(_.get()).sum
     context.write(key, sum.writable)
   }
}


