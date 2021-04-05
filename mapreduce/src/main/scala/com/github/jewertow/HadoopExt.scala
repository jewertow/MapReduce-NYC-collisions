package com.github.jewertow

import org.apache.avro.generic.GenericRecord
import org.apache.avro.mapred.AvroKey
import org.apache.hadoop.io.{IntWritable, LongWritable, NullWritable, Text}
import org.apache.hadoop.mapreduce.{Mapper, Reducer}

object HadoopExt {

  type MapperContext = Mapper[LongWritable, Text, Text, IntWritable]#Context
  type CombinerContext = Reducer[Text, IntWritable, Text, IntWritable]#Context
  type ReducerContext = Reducer[Text, IntWritable, AvroKey[GenericRecord], NullWritable]#Context

  implicit class TextExt(str: String) {
    def text: Text = new Text(str)
  }

  implicit class IntWritableExt(int: Int) {
    def writable: IntWritable = new IntWritable(int)
  }
}
