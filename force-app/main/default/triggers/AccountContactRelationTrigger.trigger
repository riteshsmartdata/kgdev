trigger AccountContactRelationTrigger on AccountContactRelation (after insert, after update) {
    new AccountContactRelationHandler('AccountContactRelationHandler').debug(false).run();
}