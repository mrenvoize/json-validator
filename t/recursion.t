use Mojo::Base -strict;
use Test::Mojo;
use Test::More;
use JSON::Validator 'validate_json';

my $data = {};
$data->{rec} = $data;

$SIG{ALRM} = sub { die 'Recursion!' };
alarm 2;
my @errors = ('i_will_be_removed');
eval { @errors = validate_json {top => $data}, 'data://main/spec.json' };
is $@, '', 'no error';
is_deeply(\@errors, [], 'avoided recursion');

my $jv = JSON::Validator->new;
my $spec = $jv->schema('data://main/spec.json')->schema->data;
my $jv2 = JSON::Validator->new->schema($spec);
@errors = ('i_will_still_be_removed');
eval { @errors = $jv2->validate({ top => $data}) };
is $@, '', 'no error';
is_deeply(\@errors, [], 'still avoided recursion');

done_testing;
__DATA__
@@ spec.json
{
  "properties": {
    "top": { "$ref": "#/definitions/again" }
  },
  "definitions": {
    "again": {
      "anyOf": [
        {"type": "string"},
        {
          "type": "object",
          "properties": {
            "rec": {"$ref": "#/definitions/again"}
          }
        }
      ]
    }
  }
}
