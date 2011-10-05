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

create, build, dist

### create

**Usage:**

    $ vizr create [-t | --type TYPE] <projectpath>

Creates a new vizr project. Right now there is only one type, but we plan on having some other boilerplate projects.

    $ vizr create project_name

To use a different boilderplate:

    $ vizr create -t basic project_name

**Boilderplates:**

* basic
