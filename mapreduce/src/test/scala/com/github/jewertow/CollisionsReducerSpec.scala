package com.github.jewertow

import org.apache.hadoop.io.{IntWritable, Text}
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

    // when
    reducer.reduce(
      key,
      values = List(new IntWritable(1), new IntWritable(2)).asJava,
      context
    )

    // then
    verify(context).write(key, new IntWritable(3))
    verifyNoMoreInteractions(context)
  }
}
