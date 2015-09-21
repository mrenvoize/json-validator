use Mojo::Base -strict;
use Test::More;
use JSON::Validator;
use Mojo::Util qw( slurp spurt );

use Data::Printer colored => 1;

my $file      = File::Spec->catfile(File::Basename::dirname(__FILE__), 'spec_split.json');
my $validator = JSON::Validator->new->schema($file);
my @errors    = $validator->validate({firstName => 'yikes!', age => 7, height => { measurement => 107, unit => 'cm' }});

is int(@errors), 1, 'one errors';
is $errors[0]->path,    '/lastName',         'lastName';
is $errors[0]->message, 'Missing property.', 'required';
is_deeply $errors[0]->TO_JSON, {path => '/lastName', message => 'Missing property.'}, 'TO_JSON';

@errors        = $validator->validate({firstName => 'yikes!', lastName => 'smith', age => 'Female', height => { measurement => 107, unit => 'cm' }});
is int(@errors), 1, 'one errors';
is $errors[0]->path,    '/age',              'age'; # Age should be an integer, so a string should fail

done_testing;
