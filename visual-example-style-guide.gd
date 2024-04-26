# A Visual Example:
@onready var code_data := {
  # variables here:
  intVar = 1, # We Use Lua Style Dictionaries To Make It Look Readable
  floatVar = 2.40, # We Can't Use Static Typing Sadly.
  stringVar = "Hello World", # We Also Add Commas At The End Of Each Line Because Of How Dictionaries Work
  boolVar = true,

  #wild stuff
  nodeVar = %NodePath # if your accessing a Unique Node/Node Path, you'll have to add the @onready keyword in your main dictionary, otherwise, just leave it be.
  preloadVar = preload("res://icon.svg") # also add an @onready notation if your doing preload/load (just to be sure!)
  
  #functions
  FuncCall = func() -> void:
    code_data.Start.call() # this is how we call callables (and access variables inside the dictionary essentially)
    pass, # just add a pass at the end of every line with a comma at the end of it (godot complains if we don't add a comma, i just put a pass so we know where the comma is.) 
  
  Start = func() -> void:
    # called once
    print(code_data.stringVar) # we don't have autocomplete inside the dictionary sadly, deal with it :/
  
  Update = func() -> void:
    # called every frame
    print(code_data.IntVar)

# a cool thing about this type of challenge is, we can sort of "mimic" a namespace with this, and add more namespaces/classes by putting another dictionary like below:
  ClassTest = {
    #variables here again
    vectorVar = Vector2(0, 20)
    arrayVar = ["foo", "bar"]

    #functions
    printFooBar = func() -> void:
      print(code_data.ClassTest.arrayVar[0] #this is how we access variables/functions inside another dictionary)
      print(code_data.ClassTest.arrayVar[0]) 
  }
}

func _ready():
  code_data.FuncCall.call() # call your FuncCall function inside ready, this is the only built in godot function we'll need.
