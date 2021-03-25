package com.github.jewertow

import java.lang
import org.apache.hadoop.io.{IntWritable, Text}
import org.apache.hadoop.mapreduce.Reducer
import scala.collection.JavaConverters._

class CollisionsReducer extends Reducer[Text, IntWritable, Text, IntWritable] {
  override def reduce(key: Text, values: lang.Iterable[IntWritable], context: Reducer[Text, IntWritable, Text, IntWritable]#Context): Unit = {
    val sum = values.asScala.map(_.get()).sum
    context.write(key, new IntWritable(sum))
  }
}
