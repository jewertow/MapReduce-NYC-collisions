package com.github.jewertow

import com.github.jewertow.HadoopExt._
import org.scalatest.mockito.MockitoSugar
import org.scalatest.FlatSpec
import org.scalatest.Matchers
import org.apache.hadoop.io.LongWritable
import org.mockito.Mockito._

class CollisionsMapperSpec extends FlatSpec with Matchers with MockitoSugar {

  private val mapper = new CollisionsMapper
  private val lineNo = new LongWritable(1)

  it should "return single result record when collision has only one type of participants" in {
    // given
    val context = mock[mapper.Context]

    // when
    mapper.map(lineNo, value = "08/03/2013,18:00,11223,,,,37 AVENUE,,,,2,0,2,0,0,0,0,0".text, context)

    // then
    verify(context).write("37 AVENUE,11223,pedestrians,injured".text, 2.writable)
    verifyNoMoreInteractions(context)
  }

  it should "return as many result records as distinct participant types participated in a collision" in {
    // given
    val context = mock[mapper.Context]

    // when
    mapper.map(lineNo, value = "08/03/2013,18:00,11223,,,,37 AVENUE,,,,4,0,2,0,1,0,1,0".text, context)

    // then
    verify(context).write("37 AVENUE,11223,pedestrians,injured".text, 2.writable)
    verify(context).write("37 AVENUE,11223,cyclist,injured".text, 1.writable)
    verify(context).write("37 AVENUE,11223,motorist,injured".text, 1.writable)
    verifyNoMoreInteractions(context)
  }

  it should "return as many result records as distinct participant and injury types participated in a collision" in {
    // given
    val context = mock[mapper.Context]

    // when
    mapper.map(lineNo, value = "08/03/2013,18:00,11223,,,,37 AVENUE,,,,4,3,2,1,1,1,1,1".text, context)

    // then
    verify(context).write("37 AVENUE,11223,pedestrians,injured".text, 2.writable)
    verify(context).write("37 AVENUE,11223,pedestrians,killed".text, 1.writable)
    verify(context).write("37 AVENUE,11223,cyclist,injured".text, 1.writable)
    verify(context).write("37 AVENUE,11223,cyclist,killed".text, 1.writable)
    verify(context).write("37 AVENUE,11223,motorist,injured".text, 1.writable)
    verify(context).write("37 AVENUE,11223,motorist,killed".text, 1.writable)
    verifyNoMoreInteractions(context)
  }

  it should "ignore collisions that happened before 2013" in {
    // given
    val context = mock[mapper.Context]

    // when
    mapper.map(lineNo, value = "08/03/2012,18:00,11223,,,,37 AVENUE,,,,2,0,2,0,0,0,0,0".text, context)

    // then
    verifyNoMoreInteractions(context)
  }

  it should "ignore collisions that have no zip code" in {
    // given
    val context = mock[mapper.Context]
    val invalidZipCodes = List("", " ", "\t")

    // when
    val results = invalidZipCodes.map { zipCode =>
      mapper.map(lineNo, value = s"08/03/2012,18:00,$zipCode,,,,37 AVENUE,,,,2,0,2,0,0,0,0,0".text, context)
    }.toSet

    // then
    // no exception was thrown
    results shouldBe Set(())
    verifyNoMoreInteractions(context)
  }

  it should "ignore collisions in case of invalid date" in {
    // given
    val context = mock[mapper.Context]

    // when
    mapper.map(lineNo, value = s"DATE_EXPECTED,18:00,11223,,,,37 AVENUE,,,,2,0,2,0,0,0,0,0".text, context)

    // then
    verifyNoMoreInteractions(context)
  }
}
