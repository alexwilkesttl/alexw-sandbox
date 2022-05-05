.PHONY: help
help:  ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean-build
clean-build:  ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

.PHONY: clean-pyc
clean-pyc:  ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

.PHONY: clean-test
clean-test:  ## remove test and coverage artifacts
	rm -fr .tox/
	rm -fr .pytest_cache/
	find . -name '.coverage' -type f -exec rm -fr {} +
	find . -name 'htmlcov' -type d -exec rm -fr {} +

.PHONY: clean
clean: clean-build clean-pyc clean-test  ## remove all build, test, coverage and Python artifacts

.PHONY: lint
lint:  ## check style with black, flake8, etc.
	pre-commit

.PHONY: req
req:  ## install required packages
	pip install --upgrade -r requirements.txt \
	            --index-url https://pypi.org/simple \
	            --trusted-host artifactory.trainline.tools \
	            --extra-index-url https://artifactory.trainline.tools/artifactory/api/pypi/pypi-internal-master/simple \
	            --timeout 120

.PHONY: dist
dist: clean  ## build Python package
	python setup.py sdist bdist_wheel
	ls -l dist
	python --version
	python setup.py --version

.PHONY: pex
pex: clean  ## build a PEX archive using docker
	docker build . -t turing_pex:latest
	docker run -ti --rm \
		--mount type=bind,source="${PWD}",target=/app \
		--mount type=volume,target=/app/.venv \
		turing_pex:latest \
		./build-pex.sh my latest