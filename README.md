# vizr 

Helpers creates templates for vizualization projects

## install

    $ git clone [git repo]
    $ cd vizr
    $ rake install

## usage

    $ vizr create new_project
    $ cd new_project
    $ vizr build .
    $ open build/index.html

## commands

`create`, `build`, `dist`, `help`

### create

Creates a new vizr project. Right now there is only one type, but we plan on having some other boilerplate project types.

**Usage:**

    $ vizr create [-t | --type TYPE] <projectpath>

Example:

    $ vizr create project_name

To use a different boilderplate:

    $ vizr create -t basic project_name

**Boilderplates:**

* `basic`

### build

Build a vizr project

**Usage:**

    $ vizr build <projectpath>

Example:

    $ vizr build .

### dist

Creates a zip file for emailing or uploading. It packages up a project `build` folder. By default it saves as `dist.zip` in the project root, you can change this with the `--filename` option.

**Usage:**

    $ vizr dist [-n | --filename NAME] <projectpath>

Example:

    $ vizr dist .

OR

    $ vizr dist --filename project.zip .
