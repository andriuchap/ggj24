extends Node

#const JokeType = preload("res://scripts/joke_type.gd")

var joke_flavors = {
	Enums.JokeType.BAD: [ 
		{"title": "Dad joke", "desc": "Ugh... dad!"}, 
		{"title": "Cringe", "desc": "Ugh!.."}],
	Enums.JokeType.CLASSIC: [
		{"title": "Bar joke", "desc":"A crow walks to the bar..."},
		{"title": "Blonde joke", "desc": "It's not a hair color, it's a lifestyle!"},
		{"title": "Knock knock joke", "desc": "Who's there?"},
		{"title": "Lightbulb joke", "desc": "Just screw in the lightbulb!"},
		{"title": "Three wishes joke", "desc": "I wonder if the genie enjoys all the rubbing?"},
		{"title": "Lawyer joke", "desc":""}],
	Enums.JokeType.DARK: [
		{"title":"Racist joke", "desc": "Don't start this one before looking over your shoulder."},
		{"title":"Dark joke", "desc":"This one's nearly as dark as my feathers."},
		{"title":"Dead baby joke", "desc":"Oh boy..."}
		],
	Enums.JokeType.VULGAR: [
		{"title":"Dick joke", "desc": "Bow down to the mighty phallus!"},
		{"title":"Toilet humor", "desc": "Eww..."},
		{"title": "Sex joke", "desc": "Aww, yeah!"}],
	Enums.JokeType.WITTY: [
		{"title":"One-liner", "desc": "Funnier than whatever James Bond caws-out."},
		{"title": "Pun", "desc": ""},
		{"title": "Throwaway", "desc": "Cool crows don't look back."},
		{"title": "Math joke", "desc": "12th graders won't get this one."}],
	Enums.JokeType.PHYSICAL: [
		{"title": "Slapstick", "desc":"BOINK! BOINK!"},
		{"title": "Body humor", "desc": "Can't top Jim CAWrrey, though."}
		]
}

@export var symbol_colors: Array[Color]

func get_color_for_type(joke_type):
	return symbol_colors[joke_type]

func get_random_flavor_for_type(joke_type):
	if joke_type == Enums.JokeType.ANY:
		joke_type = randi_range(0, joke_flavors.keys().size()-1)
	var rand_joke = randi_range(0, joke_flavors[joke_type].size()-1)
	return joke_flavors[joke_type][rand_joke].title
