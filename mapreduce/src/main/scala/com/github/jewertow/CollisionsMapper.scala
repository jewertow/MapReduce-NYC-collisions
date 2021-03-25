package com.github.jewertow

import org.apache.hadoop.io.{IntWritable, LongWritable, Text}
import org.apache.hadoop.mapreduce.Mapper

class CollisionsMapper extends Mapper[LongWritable, Text, Text, IntWritable] {

  private final val InjuryTypes = List(Injured, Killed)
  private final val CollisionParticipants = List(Pedestrians, Cyclist, Motorist)

  override def map(key: LongWritable, value: Text, context: Mapper[LongWritable, Text, Text, IntWritable]#Context): Unit = {
    if (key.get() == 0) {
      return
    }

    val columns = value.toString.split(",")
    val zipCode = columns(1)
    val street = columns(5)

    InjuryTypes.foreach { injuryType =>
      CollisionParticipants.foreach { participant =>
        val column = injuryType match {
          case Injured => participant.injuredColumn
          case Killed => participant.killedColumn
        }
        val participantsNumber = columns(column).toInt
        if (participantsNumber > 0) {
          context.write(
            new Text(s"$street,$zipCode,${participant.typeName},${injuryType.typeName}"),
            new IntWritable(participantsNumber)
          )
        }
      }
    }
  }
}
