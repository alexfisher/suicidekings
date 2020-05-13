.PHONY: build clean run 

build:
	swift build

clean:
	swift package clean
	rm -fr .build

run:
	swift run skdemo play --rounds 100 --rate 0.0005 --starting-cards 5 --bots --bot-count 10 --bank-roll 1
