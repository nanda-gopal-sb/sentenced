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


func _init(p_case_id: int = 0, p_defendant_name: String = "", p_defendant_age: int = 0,
            p_defendant_profession: String = "", p_defendant_homeState:
            GameEnums.HomeState = GameEnums.HomeState.Solis, p_charge: String = "",
            p_priority_level: int = 0, p_evidence_quality: GameEnums.Evidence_Quality = GameEnums.Evidence_Quality.LOW,
            p_summary: String = "", p_location: String = "", p_date_of_crime: String = "", p_date_of_arrest: String = "",
            p_date_of_trial: String = "", p_verdict: String = "", p_sentence: String = "", p_is_guilty: bool = false):
    self.case_id = p_case_id
    self.defendant_name = p_defendant_name
    self.defendant_age = p_defendant_age
    self.defendant_profession = p_defendant_profession
    self.defendant_homeState = p_defendant_homeState
    self.charge = p_charge
    self.priority_level = p_priority_level
    self.evidence_quality = p_evidence_quality
    self.summary = p_summary
    self.location = p_location
    self.date_of_crime = p_date_of_crime
    self.date_of_arrest = p_date_of_arrest
    self.date_of_trial = p_date_of_trial
    self.verdict = p_verdict
    self.sentence = p_sentence
    self.is_guilty = p_is_guilty


static func getCase(priority: int) -> Case:
    var file_path = "res://assets/cases/" + str(priority) + ".json"
    
    if not FileAccess.file_exists(file_path):
        print("Error: Case file not found at ", file_path)
        return null
        
    var json_string = FileAccess.get_file_as_string(file_path)
    var json = JSON.new()
    var error = json.parse(json_string)
    
    if error == OK:
        var cases_array: Array = json.data as Array
        if cases_array.is_empty():
            return null
            
        var selected_case: Dictionary = cases_array[randi_range(0, cases_array.size() - 1)]
        var char_obj = Case.new()
        
        for key in selected_case.keys():
            if key in char_obj:
                if key == "defendant_homeState":
                    char_obj.defendant_homeState = _map_string_to_homestate(selected_case[key])
                elif key == "evidence_quality":
                    char_obj.evidence_quality = _map_string_to_evidence(selected_case[key])
                else:
                    char_obj.set(key, selected_case[key])
                
        return char_obj
    else:
        print("JSON Parse Error: ", json.get_error_message())
        return null

static func _map_string_to_homestate(state_str: String) -> GameEnums.HomeState:
    match state_str:
        "Solis": return GameEnums.HomeState.Solis
        "Veridia": return GameEnums.HomeState.Veridia
        "Astraea": return GameEnums.HomeState.Astraea
        "Meridiana": return GameEnums.HomeState.Meridiana
        "Oros": return GameEnums.HomeState.Oros
    return GameEnums.HomeState.Solis # Fallback

static func _map_string_to_evidence(ev_str: String) -> GameEnums.Evidence_Quality:
    match ev_str.to_upper():
        "LOW": return GameEnums.Evidence_Quality.LOW
        "MEDIUM": return GameEnums.Evidence_Quality.MEDIUM
        "HIGH": return GameEnums.Evidence_Quality.HIGH
    return GameEnums.Evidence_Quality.LOW # Fallback