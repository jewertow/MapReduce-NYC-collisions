package com.github.jewertow

import com.github.jewertow.HadoopExt._
import java.lang
import org.apache.hadoop.io.{IntWritable, Text}
import org.apache.hadoop.mapreduce.Reducer
import scala.collection.JavaConverters._

class CollisionsReducer extends Reducer[Text, IntWritable, Text, IntWritable] {
  override def reduce(key: Text, values: lang.Iterable[IntWritable], context: ReducerContext): Unit = {
    val sum = values.asScala.map(_.get()).sum
    context.write(key, sum.writable)
  }
}
