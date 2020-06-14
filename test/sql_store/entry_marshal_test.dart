import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:free_authenticator/model/api/entry_type.dart';
import 'package:free_authenticator/sql_store/entry_marshal.dart';

const COLUMN_TYPE = 'type';
const COLUMN_POSITION = 'position';
const COLUMN_VAULT = 'vault';
const COLUMN_DATA = 'data';
const TYPE_VAULT = 1;
const DATA_NAME = 'name';
const DATA_SECRET = 'secret';
const DATA_TIMESTEP = 'timestep';

Future<String> encryptJson(Map<String, dynamic> data) async {
  return jsonEncode(data);
}

void main() {
  test('Marshal requires fields', () async {
    var err;
    try {
      await EntryMarshal.marshal(EntryType.vault, encryptJson, vault: 4, name: "");
    } catch(e) {
      err = e;
    }
    expect(err, isNotNull);
    expect(err.toString(), contains("Missing field position"));

    err = null;
    try {
      await EntryMarshal.marshal(EntryType.vault, encryptJson, position: 5, name: "");
    } catch(e) {
      err = e;
    }
    expect(err, isNotNull);
    expect(err.toString(), contains("Missing field vault"));

    err = null;
    try {
      await EntryMarshal.marshal(EntryType.vault, encryptJson, position: 5, vault: 7);
    } catch(e) {
      err = e;
    }
    expect(err, isNotNull);
    expect(err.toString(), contains("Missing field name"));
  });

  test('New vault marshal', () async {
    final name = "my vault";
    final position = 3;
    final vault = 1;

    final marshalled = await EntryMarshal.marshal(EntryType.vault, encryptJson,
      position: position, vault: vault,
      name: name,
    );

    expect(marshalled[COLUMN_TYPE], equals(TYPE_VAULT));
    expect(marshalled[COLUMN_POSITION], equals(position));
    expect(marshalled[COLUMN_VAULT], equals(vault));
    Map<String, dynamic> marshalledData = jsonDecode(marshalled[COLUMN_DATA]);
    expect(marshalledData, allOf([
      contains(DATA_NAME),
      isNot(contains(DATA_SECRET)),
      isNot(contains(DATA_TIMESTEP)),
    ]));
    expect(marshalledData[DATA_NAME], equals(name));
  });

  test('Vault marshal only includes vault data', () async {
    final marshalled = await EntryMarshal.marshal(EntryType.vault, encryptJson,
      position: 5, vault: 7,
      name: "my vault", secret: "secret", timestep: 30
    );
    
    Map<String, dynamic> marshalledData = jsonDecode(marshalled[COLUMN_DATA]);
    expect(marshalledData, allOf([
      contains(DATA_NAME),
      isNot(contains(DATA_SECRET)),
      isNot(contains(DATA_TIMESTEP)),
    ]));
  });
}
