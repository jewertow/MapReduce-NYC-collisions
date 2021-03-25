package com.github.jewertow

import org.apache.hadoop.io.{IntWritable, LongWritable, Text}
import org.apache.hadoop.mapreduce.Mapper
import com.github.jewertow.HadoopExt._

class CollisionsMapper extends Mapper[LongWritable, Text, Text, IntWritable] {

  private final val InjuryTypes = List(Injured, Killed)
  private final val CollisionParticipants = List(Pedestrians, Cyclist, Motorist)

  override def map(key: LongWritable, value: Text, context: MapperContext): Unit = {
    if (key.get() == 0) {
      return
    }

    val columns = value.toString.split(",")
    val date = columns(0)
    val zipCode = columns(1)
    val street = columns(5)

    val year = date.split("/")(2).toInt
    if (year <= 2012 || zipCode.isEmpty || zipCode.trim.isEmpty) {
      return
    }

    InjuryTypes.foreach { injuryType =>
      CollisionParticipants.foreach { participant =>
        val column = injuryType match {
          case Injured => participant.injuredColumn
          case Killed => participant.killedColumn
        }
        val participantsNumber = columns(column).toInt
        if (participantsNumber > 0) {
          context.write(
            s"$street,$zipCode,${participant.typeName},${injuryType.typeName}".text,
            participantsNumber.writable
          )
        }
      }
    }
  }
}
