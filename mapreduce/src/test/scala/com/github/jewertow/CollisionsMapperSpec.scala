package com.github.jewertow

import org.scalatest.mockito.MockitoSugar
import org.scalatest.FlatSpec
import org.apache.hadoop.io.{IntWritable, LongWritable, Text}
import org.mockito.Mockito._

class CollisionsMapperSpec extends FlatSpec with MockitoSugar {
  it should "return single result record when collision has only one type of participants" in {
    // given
    val mapper = new CollisionsMapper
    val context = mock[mapper.Context]

    // when
    mapper.map(
      key = new LongWritable(1),
      value = new Text("date-todo,11223,,,,37 AVENUE,,,,2,0,2,0,0,0,0,0"),
      context
    )

    // then
    verify(context).write(
      new Text("37 AVENUE,11223,pedestrians,injured"),
      new IntWritable(2)
    )
    verifyNoMoreInteractions(context)
  }

  it should "return as many result records as distinct participant types participated in a collision" in {
    // given
    val mapper = new CollisionsMapper
    val context = mock[mapper.Context]

    // when
    mapper.map(
      key = new LongWritable(1),
      value = new Text("date-todo,11223,,,,37 AVENUE,,,,4,0,2,0,1,0,1,0"),
      context
    )

    // then
    verify(context).write(
      new Text("37 AVENUE,11223,pedestrians,injured"),
      new IntWritable(2)
    )
    verify(context).write(
      new Text("37 AVENUE,11223,cyclist,injured"),
      new IntWritable(1)
    )
    verify(context).write(
      new Text("37 AVENUE,11223,motorist,injured"),
      new IntWritable(1)
    )
    verifyNoMoreInteractions(context)
  }

  it should "return as many result records as distinct participant and injury types participated in a collision" in {
    // given
    val mapper = new CollisionsMapper
    val context = mock[mapper.Context]

    // when
    mapper.map(
      key = new LongWritable(1),
      value = new Text("date-todo,11223,,,,37 AVENUE,,,,4,3,2,1,1,1,1,1"),
      context
    )

    // then
    verify(context).write(
      new Text("37 AVENUE,11223,pedestrians,injured"),
      new IntWritable(2)
    )
    verify(context).write(
      new Text("37 AVENUE,11223,pedestrians,killed"),
      new IntWritable(1)
    )
    verify(context).write(
      new Text("37 AVENUE,11223,cyclist,injured"),
      new IntWritable(1)
    )
    verify(context).write(
      new Text("37 AVENUE,11223,cyclist,killed"),
      new IntWritable(1)
    )
    verify(context).write(
      new Text("37 AVENUE,11223,motorist,injured"),
      new IntWritable(1)
    )
    verify(context).write(
      new Text("37 AVENUE,11223,motorist,killed"),
      new IntWritable(1)
    )
    verifyNoMoreInteractions(context)
  }
}
