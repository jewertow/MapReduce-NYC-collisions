package com.github.jewertow

import org.apache.avro.generic.{GenericData, GenericRecord}
import org.apache.avro.mapred.AvroKey
import org.apache.hadoop.io.{IntWritable, NullWritable, Text}
import org.mockito.Mockito.{verify, verifyNoMoreInteractions}
import org.scalatest.FlatSpec
import org.scalatest.mockito.MockitoSugar

import scala.collection.JavaConverters._

class CollisionsReducerSpec extends FlatSpec with MockitoSugar {
  it should "sum received values" in {
    // given
    val reducer = new CollisionsReducer
    val context = mock[reducer.Context]
    val key = new Text("37 AVENUE,11223,pedestrians,injured")

    val expectedRecord = new GenericData.Record(CollisionsReducer.CollisionsSchema)
    expectedRecord.put("street", "37 AVENUE")
    expectedRecord.put("zip_code", "11223")
    expectedRecord.put("person_type", "pedestrians")
    expectedRecord.put("injury_type", "injured")
    expectedRecord.put("participants_number", 3)

    // when
    reducer.reduce(
      key,
      values = List(new IntWritable(1), new IntWritable(2)).asJava,
      context
    )

    // then
    verify(context).write(new AvroKey[GenericRecord](expectedRecord), NullWritable.get())
    verifyNoMoreInteractions(context)
  }
}
