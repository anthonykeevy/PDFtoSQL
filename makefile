.PHONY: setup clean

# "setup" target: create venv and install dependencies
setup:
	python -m venv .venv
	. .venv/bin/activate && pip install --upgrade pip
	. .venv/bin/activate && pip install -r requirements.txt

# "clean" target: remove the venv folder
clean:
	rm -rf .venv