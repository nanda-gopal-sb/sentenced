class_name Case
extends RefCounted

var case_id: int
var defendant_name: String
var defendant_age: int
var defendant_profession: String
var defendant_homeState: GameEnums.HomeState
var charge: String
var priority_level: int
var evidence_quality: GameEnums.Evidence_Quality
var summary: String
var location: String
var date_of_crime: String
var date_of_arrest: String
var date_of_trial: String
var verdict: String # DDMMYY
var sentence: String # DDMMYY
var is_guilty: bool

