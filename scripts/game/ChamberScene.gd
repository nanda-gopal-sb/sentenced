extends Node

var current_case: Case = null


func _ready() -> void:
    load_new_case_by_priority(5)


func load_new_case_by_priority(priority: int) -> void:
    current_case = Case.getCase(priority)    
    if current_case != null:
        print("Successfully loaded case ID: ", current_case.defendant_name)
    else:
        print("Failed to populate case file.")