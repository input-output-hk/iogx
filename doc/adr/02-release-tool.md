# Release tool

Create an executable that provides high-level and content-focused controls for
creating releases from repositories using IOGX.

## Motivation

For engineers focused on the development and maintenance of a product, releases
are only a means to distribute their works in a way that they are strongly
associated with an identifier that can be clearly communicated to users
(typically a version number).

For these engineers, any actions they have to take or decisions they have to
make, that don't provide real control over what works are distributed in
releases and when releases are made, are complexities they face in pursuit of
their goal.

To manage these complexities engineers require knowledge that is very irrelevant
to the products they support and other complexities the manage frequently.

We seek to remove those complexities from those engineers' workflows while
providing controls useful for controlling what works are distributed in
releases.

## Exclusions

### Release Scheduling

There is a need for better solutions for release scheduling, but this ADR will
focus on providing a solution that integrates well with the tools and processes
the smart contracts teams are already using to schedule release, mainly Github
Actions and manually creating releases.

## Current state

Currently, iogx does not provide any utilities for users to create software
releases. This leaves users to manually create software releases, document
complex releases processes and create custom release automation configurations
and scripts, or get assistance from SCDE to do so.

Not all repositories create any notion of a release, but the ones that do,
preform releases with a few methods.

- Manually preform specific actions to create releases according to specific
desired outcomes.
- Manually preform specific actions to create releases according to a notion of
convention across IOG or wider contexts.
- Manually preform specific actions to create releases according to documented
processes.
- Creating custom release scripts and manually invoking them.
- Configuring GitHub actions to automatically invoke custom release scripts on
specific events and schedules and under specific conditions.

The manual processes are prone to errors and in-material inconsistencies from
release to release. This is because manually creating release is a processes
that contains many decisions and processes and is typically preformed
in-frequently. Meaning it is a task that engineers likely have not done in a
while, and have to make a lot of un-familiar decisions to complete.

Fallowing conventions can help provide some consistency and prevent some
errors and fallowing a documented process helps even more so, but when a
engineer manually preforms these steps there is a chance for novel hard to
debug issues to affect releases.

The projects that use release scripts and automations can provide more consistent
error-free releases, and with less of a burden on everyone supporting the
releases for the project, per release. The issue with the projects that have
automations is that the automation code for every project is separate but seeks
to achieve similar results and very detailed in how to produce releases.

The automation code being very detailed in how to produce releases leads to
projects seeking support from SCDE. This means that both the team owning the
project and SCDE has to be involved in maintaining the release automations for
the project. This leads to the SCDE team having to provide direct support for
most projects that have release automations. Given that each project has its own
separate automation code, this means that the SCDE team is given a lot of
maintenance burden between all the projects producing releases, and faces
scaling issues with the growth of the number of projects producing releases.

## Solution

Create an executable that provides users with high-level and content-focused
controls for creating releases from repositories that use IOGX. When invoked,
the executable ensures that the appropriate works are distributed according to
the users use of the [Release Configuration](#release-configuration) and in a
way that associates their works to an [Release Identifier](#release-identifier)
specified by the user.

### Interface

The executable is a non-interactive executable.

Its inputs are arguments provided via the command line and values in a
`release.y(a)ml` file at the root of a git repository that is using IOGX.

> [!NOTE]
> The executable does use tools that take other inputs, specifically
configuration files and environment variables present in the environment the
executable is executed from, as well as information from services accessible by
the executable.

#### Parameters

##### `RELEASE_ID` (Param)

- Position: 0
- Type: String
- Required

The [Release Identifier](#release-identifier).

#### Release Configuration

The [Release Configuration](#release-configuration) acts that the main set of
[Controls](#controls) provided to the user. As [Controls](#controls), the values
user provides for the [Release Configuration](#release-configuration) determines
which [Objectives](#objective-notion) are [User Objectives](#user-objective),
what parameters are used in those [Objectives](#objective-notion) and ultimately
what the contents of the [Release Plan](#release-plan).

For the `create_release` executable to work there needs to be a `release.yml` or
`release.yaml` file at the root of the git repository using IOGX.

See [Release Configuration Options](#release-configuration-options)

#### Behavior

When the release executable is executed, the executable preforms a few steps...

##### 1. Parse Inputs

Attempt to parse the inputs.

> [!NOTE]
> In this step the executable is only parsing the inputs to the point that it
can have high-level information as to the users intentions for the release.

Steps

1. Attempt to parse the inputs.
    1. If there are any parsing errors...
        1. For each parsing error...
            1. Display the parsing error.
            2. Display a message to help the user resolve the parsing error.
        2. Exit with a message and an error code.
    2. If there are no parsing errors, continue to the next step.

Example

```Console
Error: Value of "git.tag.always-publish" in release.yaml was "Hi".
Expected values for "git.tag.always-publish" are "True" and "False".
Error: Value of "github.release.assets.bar" in release.yaml contains unexpected key "outputs".
Expected keys for "github.release.assets.<name>" are "output" and "path".
Error: Issues with configuration in "release.yaml". No release actions preformed. Exiting...
```

##### 2. Create the release plan

Create the release plan by checking the
[Release Configuration](#release-configuration) for what
[Objectives](#objectives) to attempt.

> [!NOTE]
> The executable attempts to only do the minimal amount of consequential actions
possible to achieve what it understands is the end state the user is expecting.

The [Indicators](#indicators) are used to determine what
[Objectives](#objectives) to are in the release plan.

Steps

1. For all [Indicators](#indicators), preform the [Indicator's](#indicators)
check. If the check succeeds, add the [Objectives](#objectives) to the
release plan if it is not already included.
2. If no [Objectives](#objectives) are in the release plan, display a message
saying that there is nothing to for the release tool to do and why, then exit.
3. Display the release plan.

#### 3. Enact the Release Plan

Attempt to achieve all of the [Objectives](#objectives) in the release plan.

1. For all [Objective](#objectives) in the release plan.
  1. Display a description of the [Objective](#objectives) to be attempted.
  2. Attempt to achieve the [Objective](#objectives).
      1. If it succeeds...
          1. Display that the [Objective](#objectives) has been achieved.
          2. Continue to the next [Objective](#objectives).
      2. If it fails
          1. Display an error message describing that the executable failed to
          achieve the [Objective](#objectives).
          2. Exit with an error message explaining that the
          release plan failed.
2. Display a message saying that the release was successful.

#### Examples

##### Release Assets

###### Given

There is no `v0.1.0` tag locally or on GitHub.

`release.yaml`

```yaml
git:
  tag:
    prefix: "v"
description:
  include-github-generated-release-notes: true
github:
  release:
    assets:
      foo-x86_64-linux:
        output: packages.x86_64-linux.foo
        path: /lib/foo.so
```

###### When

```console
# create_release 0.1.0
```

###### Then

> [!NOTE]
> Because of the [Assets to publish (Indicator)](#assets-to-publish-indicator)
the [Release on GitHub (Objective)](#release-on-github-objective) will be
attempted.

```console
Release Plan
1. Create GitHub Release "0.1.0"

Enacting release plan...
Creating git tag "v0.1.0" locally...
Local git tag created.
Pushing git tag "v0.1.0" to GitHub...
Tag on GitHub.
Creating Release "0.1.0" on GitHub...
Release created on GitHub.
Release plan successfully completed.
```

##### Release Git tag+GitHub Release, no GitHub permission

###### Given

There is no `v0.2.1-beta1` tag or release on GitHub, and the user does not have
permission to push tags to the git repository on GitHub.

`release.yaml`

```yaml
description:
  include-github-generated-release-notes: true
git:
  tag:
    always-publish: True
github:
  release:
    always-publish: True
```

###### When

```console
create_release v0.2.1-beta1
```

###### Then

> [!NOTE]
> Because of the
[GitHub release published (Indicator)](#github-release-published-indicator)
the [Release on GitHub (Objective)](#release-on-github-objective) will be
attempted.

> [!NOTE]
> Because of the [Git tag published (Indicator)](#git-tag-published-indicator)
the [Tag on GitHub (Objective)](#release-on-github-objective) will be attempted.

```console
Release Plan
1. Push tag to GitHub
2. Create GitHub Release

Enacting release plan...
Creating local git tag...
Local git tag created.
Pushing git tag to GitHub...
error: Failed to push tag to GitHub!
git: Permission denied
Release plan failed.
```

## Indicators

[Indicators](#indicators) are checks on the
[Release Configuration](#release-configuration) for what
[Objectives](#objectives) the executable needs to attempt to achieve.

### Assets to publish (Indicator)

The user wants the assets they provided to be published.

- Check: [`github.release.assets`](#github-release-assets) is not the Empty Map
- Objectives:
  - [Release on GitHub (Objective)](#release-on-github-objective).

### GitHub release published (Indicator)

The user wants a GitHub release published.

- Check: [`github.release.always-publish`](#github-release-always-publish) is a
truthy value.
- Objectives:
  - [Release on GitHub (Objective)](#release-on-github-objective)

### Git tag published (Indicator)

The user wants the git tag to be published.

- Check: [`git.tag.always-publish`](#git-tag-always-publish) is a truthy value
then.
- Objectives:
  - [Tag on GitHub (Objective)](#tag-on-github-objective)

## Objectives

[Objectives](#objectives) are things that executable can attempt to achieve.

The [Indicators](#indicators) decide what [Objectives](#objective) need to be
achieved in-order to create the release.

For each [Objective](#objectives) the executable will preform a series of
checks and actions to attempt to achieve the [Objective](#objectives). The
attempt to achieve the [Objective](#objectives) will conclude in a success
or a failure.

### Release on GitHub (Objective)

If a release for a tag with the name [Git Tag (Value)](#git-tag-value)...

- Does not exist on GitHub, then the executable attempts...
    1. [Tag on GitHub (Objective)](#tag-on-github-objective).
    2. To create a release for the tag [Git Tag (Value)](#git-tag-value), with a
    title of [Release Title (Value)](#release-title-value), a description starting
    with the value of [`description.text`](#description-text) (if it is not an
    empty string) and ending with release notes generated from GitHub (if
    [`description.include-github-generated-release-notes`](#description-include-github-generated-release-notes)
    is a truthy value), and assets from
    [`github.release.assets`](#github-release-assets) using the keys from the map
    as asset names on GitHub and the files from the built `flake-output-path`s of
    the values as the asset content.
      - If it fails, the objective has failed.
      - If it succeeds, the objective has been achieved.
- Does exist, the objective has failed.

### Tag on GitHub (Objective)

If a tag with the name [Git Tag (Value)](#git-tag-value)...

- Does not exist on GitHub, the executable attempts...
  - [Local Tag (Objective)](#local-tag-objective)
  - To push the local tag [Git Tag (Value)](#git-tag-value) to GitHub.
    - If it fails, the objective has failed.
    - If it succeeds, the objective has been achieved.
- Exist on GitHub, the executable checks if the tag on GitHub points to the same
commit as the local tag with the name [Git Tag (Value)](#git-tag-value)...
  - If it does, the objective has been achieved.
  - If it does not, the objective has failed.

### Local Tag (Objective)

If a tag with the name [Git Tag (Value)](#git-tag-value)...

- Does not exist locally, the executable attempts to create a lightweight tag
named [Git Tag (Value)](#git-tag-value) pointing the current HEAD locally.
  - If it fails, the objective has failed.
  - If it succeeds, the objective has been achieved.
- Exist locally, the executable checks if it points to the current HEAD...
  - If it does, the objective has been achieved.
  - If it does not, the objective has failed.

## Values

### Git Tag (Value)

A string that will be used to represent the release in git tags.

Value: `git.tag.prefix+RELEASE_ID`

### Release Title (Value)

A string that will be used as the "Title" of the release in content meant for
humans to read.

Value: `title.prefix+RELEASE_ID`

## Release Identifier

The [Release Identifier](#release-identifier) is simply a string unique to
each release. It is used as the foundation for every identifier representing the
content distributed under the release.

## Release Configuration Options

### `title.prefix`

- Type: String
- Default: Empty String

A prefix combined with the [Release Identifier](#release-identifier)
to form a release title to be used in content where human readability is important.

### `description.text`

- Type: String
- Default: Empty String

A description of the release.

### `description.include-github-generated-release-notes`

- Type: Bool
- Default: False

Whether to include the release notes generated by GitHub in the descriptions of
the release.

### `git.tag.always-publish`

- Type: Bool
- Default: False

If the git tag should be published even if no release objectives call for it.

### `git.tag.prefix`

- Type: String
- Default: Empty String

A string prepended to the [Release Identifier](#release-identifier) to
form the git tag representing the release in git repositories.

### `github.release.always-publish`

- Type: Bool
- Default: False

If the GitHub release should be published even if no other release objectives
call for it.

### `github.release.assets`

- Type: Mapping (String -> `flake-output-path`)
- Default: Empty Map

A mapping from the desired name of the asset in the GitHub release to the file
to exist under that asset name.

> [!NOTE]
> All values (`flake-output-path`s) must resolve to files.

<!-- -->
> [!NOTE]
> There cannot be any naming conflicts between names to be used as asset names
in the GitHub release.

Example

The configuration...

```yaml
github:
  release:
    assets:
      foo-x86_64-linux:
        output: packages.x86_64-linux.foo
        path: /lib/foo.so
      foo2-x86_64-linux:
        output: packages.x86_64-linux.foo
        path: /lib/foo2.so
      bar:
        output: packages.x86_64-linux.bar
      biz: biz
```

results in the files at these paths being uploaded to GitHub.

```console
/nix/store/XXXXXXXX-foo-derivation/lib/foo.so -> foo-x86_64-linux
/nix/store/XXXXXXXX-foo-derivation/lib/foo2.so -> foo2-x86_64-linux
/nix/store/XXXXXXXX-bar-derivation -> bar
/nix/store/XXXXXXXX-biz-derivation -> biz-x86_64-linux
```

#### `flake-output-path` Type

In the release configuration file, a `flake-output-path` is a value that
represents a node from a path in a derivation accessible from a project's flake
`outputs`. To use the node, the derivation needs to be built first.

A `flake-output-path` value can take one of the forms...

1. A string representing a selector of a derivation from the flake's `outputs`
2. A map containing the keys
    - `output` - A string representing a selector of a derivation from the flake's
    `outputs`.
    - `path` - An optional file path that will be used to select a file from the
    derivation once it has been built.

Examples

```yaml
- apps.x86_64-linux.foo
- output: devShell.x86_64-linux
- output: packages.x86_64-linux.bar
  path: /bin/bar
- output: packages.x86_64-linux.bizz
  path: /lib
```
