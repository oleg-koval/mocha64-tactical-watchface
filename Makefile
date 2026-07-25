.PHONY: build sim test lint package deploy clean hooks key doctor

NAME    := starter-face
DEVICE  ?= fenix6pro
JUNGLE  := monkey.jungle
KEY     ?= $(HOME)/.Garmin/ConnectIQ/developer_key.der
APP     := bin/$(NAME).prg
IQ      := bin/$(NAME).iq
WATCH   := /Volumes/GARMIN/GARMIN/APPS

build:
	@mkdir -p bin
	monkeyc -f $(JUNGLE) -d $(DEVICE) -o $(APP) -y $(KEY) -w -l 2

lint:
	@mkdir -p bin
	monkeyc -f $(JUNGLE) -d $(DEVICE) -o /dev/null -y $(KEY) -w -l 3

sim:
	@connectiq &
	@sleep 4
	monkeydo $(APP) $(DEVICE)

test:
	@mkdir -p bin
	monkeyc -f $(JUNGLE) -d $(DEVICE) -o $(APP) -y $(KEY) -w -l 2 --unit-test
	monkeydo $(APP) $(DEVICE) -t

package:
	@mkdir -p bin
	monkeyc -f $(JUNGLE) -e -r -o $(IQ) -y $(KEY) -w -l 3
	@echo "Store package: $(IQ)"

deploy: build
	@test -d $(WATCH) || { echo "ERROR: watch not mounted at $(WATCH)"; exit 1; }
	cp $(APP) $(WATCH)/
	@echo "Copied to watch. Eject, then pick the face on-device."

key:
	@test ! -f $(KEY) || { echo "Key already exists at $(KEY)"; exit 1; }
	@mkdir -p $(dir $(KEY))
	openssl genrsa -out $(KEY:.der=.pem) 4096
	openssl pkcs8 -topk8 -inform PEM -outform DER -nocrypt \
		-in $(KEY:.der=.pem) -out $(KEY)
	@echo "Developer key written to $(KEY) — back it up, never commit it."

doctor:
	@printf 'java     '; java -version 2>&1 | head -1 || echo MISSING
	@printf 'monkeyc  '; command -v monkeyc || echo MISSING
	@printf 'monkeydo '; command -v monkeydo || echo MISSING
	@printf 'key      '; test -f $(KEY) && echo $(KEY) || echo "MISSING — run: make key"

clean:
	rm -rf bin/

hooks:
	pre-commit install
