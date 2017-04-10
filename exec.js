var program = process.argv[2];
var prog = require(program);
var context = {};

context.log = console.log;
context.bindings = {};

context.done = function(err) {
    if (err) {
        console.log("ERROR: ", err);
        process.exit(1);

    } else {
        console.log("Result: ",  context.bindings);
        process.exit(0);

    }
};

context.error = function(err) {
    console.log("ERROR: ", err);
    process.exit(1);
};

var args = prog.testargs();
prog(context, args[0], args[1], args[2], args[3], args[4]);