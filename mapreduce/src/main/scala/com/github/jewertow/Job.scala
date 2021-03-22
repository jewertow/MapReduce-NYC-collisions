package com.github.jewertow

import org.apache.hadoop.conf.Configured
import org.apache.hadoop.io.{DoubleWritable, IntWritable, LongWritable, MapWritable, Text}
import org.apache.hadoop.util.Tool
import org.apache.hadoop.util.ToolRunner
import org.apache.hadoop.mapreduce.Job
import org.apache.hadoop.mapreduce.Mapper
import org.apache.hadoop.mapreduce.Reducer
import org.apache.hadoop.fs.Path
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat


object Job {

  sealed abstract class InjuryType {
    def typeName: String
    def column: Int
  }

  case object Injured extends InjuryType {
    def typeName = "injured"
    def column = 9
  }

  case object Killed extends InjuryType {
    def typeName = "killed"
    def column = 10
  }

  sealed abstract class CollisionParticipant {
    def typeName: String
    def injuredColumn: Int
    def killedColumn: Int
  }

  case object Pedestrians extends CollisionParticipant {
    override def typeName: String = "pedestrians"
    override def injuredColumn: Int = 11
    override def killedColumn: Int = 12
  }

  case object Cyclist extends CollisionParticipant {
    override def typeName: String = "cyclist"
    override def injuredColumn: Int = 13
    override def killedColumn: Int = 14
  }

  case object Motorist extends CollisionParticipant {
    override def typeName: String = "motorist"
    override def injuredColumn: Int = 15
    override def killedColumn: Int = 16
  }

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
}
