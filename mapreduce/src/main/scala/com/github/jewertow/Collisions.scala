package com.github.jewertow

sealed abstract class InjuryType {
  val typeName: String
}

case object Injured extends InjuryType {
  override val typeName = "injured"
}

case object Killed extends InjuryType {
  override val typeName = "killed"
}

sealed abstract class CollisionParticipant {
  val typeName: String
  val injuredColumn: Int
  val killedColumn: Int
}

case object Pedestrians extends CollisionParticipant {
  override val typeName: String = "pedestrian"
  override val injuredColumn: Int = 11
  override val killedColumn: Int = 12
}

case object Cyclist extends CollisionParticipant {
  override val typeName: String = "cyclist"
  override val injuredColumn: Int = 13
  override val killedColumn: Int = 14
}

case object Motorist extends CollisionParticipant {
  override val typeName: String = "motorist"
  override val injuredColumn: Int = 15
  override val killedColumn: Int = 16
}
