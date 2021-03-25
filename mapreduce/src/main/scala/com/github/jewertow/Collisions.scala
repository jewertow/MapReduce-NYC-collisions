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
  override val typeName: String = "pedestrians"
  override val injuredColumn: Int = 12
  override val killedColumn: Int = 13
}

case object Cyclist extends CollisionParticipant {
  override val typeName: String = "cyclist"
  override val injuredColumn: Int = 14
  override val killedColumn: Int = 15
}

case object Motorist extends CollisionParticipant {
  override val typeName: String = "motorist"
  override val injuredColumn: Int = 16
  override val killedColumn: Int = 17
}
