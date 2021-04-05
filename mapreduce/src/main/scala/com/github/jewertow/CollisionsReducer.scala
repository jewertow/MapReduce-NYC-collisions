package com.github.jewertow

import com.github.jewertow.HadoopExt._
import java.lang

import com.github.jewertow.CollisionsReducer.CollisionsSchema
import org.apache.avro.Schema
import org.apache.avro.generic.{GenericData, GenericRecord}
import org.apache.avro.mapred.AvroKey
import org.apache.hadoop.io.{IntWritable, NullWritable, Text}
import org.apache.hadoop.mapreduce.Reducer

import scala.collection.JavaConverters._

class CollisionsReducer extends Reducer[Text, IntWritable, AvroKey[GenericRecord], NullWritable] {

   override def reduce(key: Text, values: lang.Iterable[IntWritable], context: ReducerContext): Unit = {
     val sum = values.asScala.map(_.get()).sum
     val columns = key.toString.split(",")
     val record = new GenericData.Record(CollisionsSchema)
     record.put("street", columns(0))
     record.put("zip_code", columns(1))
     record.put("person_type", columns(2))
     record.put("injury_type", columns(3))
     record.put("participants_number", sum)
     context.write(new AvroKey[GenericRecord](record), NullWritable.get())
   }
}

object CollisionsReducer {
  final val CollisionsSchema = new Schema.Parser().parse(
    """
      |{
      | "type": "record",
      | "name": "Collisions",
      | "fields": [
      |   {"name":"street","type":"string"},
      |   {"name":"zip_code","type":"string"},
      |   {"name":"person_type","type":"string"},
      |   {"name":"injury_type","type":"string"},
      |   {"name":"participants_number","type":"int"}
      | ]
      |}
      |""".stripMargin
  )
}
