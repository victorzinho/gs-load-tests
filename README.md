# GeoServer load tests

Perform load tests using [JMeter](https://jmeter.apache.org/) in three easy steps:

* Setup: adapt `.jmx` template and create text files with BBOX parameters to use, manually =(.
* Generate tests (`generate_tests.sh`)
* Run (`run.sh`)


## Setup

In order to generate your tests, first you need to modify the template. Open `gs-load-template.jmx` with JMeter (using GUI) and change the parameters in the `GetMap Defaults` section to fit your needs (server, port, path, layers, etc).

Then, we need to create some files containing the bounds (value for BBOX parameter) we want to test. Each file must have 18 rows (can have more, but will be ignored) with the following format:

```
<minx>,<miny>,<maxx>,<maxy>
```

For example:

```
-70.3125,-14.0625,-69.609375,-13.359375
-70.3125,-14.765625,-69.609375,-14.0625
-69.609375,-14.0625,-68.90625,-13.359375
-70.3125,-15.46875,-69.609375,-14.765625
-69.609375,-14.765625,-68.90625,-14.0625
-68.90625,-14.0625,-68.203125,-13.359375
-69.609375,-15.46875,-68.90625,-14.765625
-70.3125,-16.171875,-69.609375,-15.46875
-68.90625,-14.765625,-68.203125,-14.0625
-69.609375,-16.171875,-68.90625,-15.46875
-68.90625,-15.46875,-68.203125,-14.765625
-68.203125,-14.0625,-67.5,-13.359375
-68.203125,-14.765625,-67.5,-14.0625
-68.90625,-16.171875,-68.203125,-15.46875
-68.203125,-15.46875,-67.5,-14.765625
-67.5,-14.0625,-66.796875,-13.359375
-68.203125,-16.171875,-67.5,-15.46875
-67.5,-15.46875,-66.796875,-14.765625
```

The only way I found to do this is to manually open a viewer (Layer Preview in GeoServer, for example), zoom to a region and copy the BBOX parameters to a file.

I found it easier in Chrome since it has the *Copy All as cURL*. Then, use bash to obtain only BBOX:

```
grep -o "BBOX=[^']*" scales | sed 's/BBOX=//g'
```

## Generate tests

Once all the scale files have been generated in the same directory, it's time to generate tests, specifying the list of user quantities to use. For example, this:

```bash
$ ./generate_tests.sh -s <directory_with_scales> 1 2 5
```

will generate 3 tests for each scale, using 1, 2 and 5 users each time.

Each user will perform 18 requests **once** in a single second, emulating the browser's behavior (6 requests per domain; assuming 3 domains for the GeoServer instance).

If you want to keep performing these requests repeatedly in a loop (until stopped; Ctrl + C):

```bash
$ ./generate_tests.sh -s <directory_with_scales> -l 1 2 5
```

## Run

Once the tests are generated, execute them:

```bash
$ ./run.sh gs-scale-*.jmx
```

It is possible to specify a timeout (`-t`) for tests (useful for tests in a loop) and/or a sleep time (`-s`) between tests:

```bash
$ ./run.sh -t 60 -s 30 gs-scale-*.jmx
```



## More scripts

It is possible to generate tests for a different number of users, taking any set of `.jmx` as source. For example, this will generate tests for 5 users for all scales:

```bash
$ ./change_users.sh 5 gs-scale-scale_*_1.jmx
```

It is also possible to generate tests with loop (running repeatedly until stopped), taking any set of `.jmx` as source. For example, this will generate tests with loop for all previously generated tests:

```bash
$ ./set_loop.sh gs-scale-scale_*jmx

```

