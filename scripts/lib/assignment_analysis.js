'use strict';

const UUID_V4_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

/** @param {string} itemId @param {string} containerId @returns {string} */
function deterministicId(itemId, containerId) {
  return `${itemId}__${containerId}`;
}

/** @param {string} id @returns {boolean} */
function isUuidId(id) {
  return UUID_V4_RE.test(id);
}

/**
 * @param {Array<{ docId: string, data: { itemId: string, containerId: string, count: number, id: string } }>} docs
 * @returns {Map<string, Array<{ docId: string, data: object }>>}
 */
function groupByPair(docs) {
  const map = new Map();
  for (const doc of docs) {
    const key = deterministicId(doc.data.itemId, doc.data.containerId);
    if (!map.has(key)) map.set(key, []);
    map.get(key).push(doc);
  }
  return map;
}

/**
 * @param {Array<{ docId: string, data: object }>} docs
 * @returns {{ alreadyMigrated: Array, clean: Array, duplicates: Array<Array> }}
 */
function classifyAssignments(docs) {
  const alreadyMigrated = [];
  const clean = [];
  const duplicates = [];

  const groups = groupByPair(docs);
  for (const [key, group] of groups) {
    if (group.length === 1 && group[0].docId === key) {
      alreadyMigrated.push(group[0]);
    } else if (group.length === 1) {
      clean.push(group[0]);
    } else {
      duplicates.push(group);
    }
  }

  return { alreadyMigrated, clean, duplicates };
}

/**
 * @param {Array<{ docId: string, data: { count: number } }>} group
 * @returns {{ winner: { docId: string, data: object }, discarded: Array<{ docId: string, data: object }> }}
 */
function resolveWinner(group) {
  let winner = group[0];
  for (let i = 1; i < group.length; i++) {
    if (group[i].data.count > winner.data.count) {
      winner = group[i];
    }
  }
  const discarded = group.filter((d) => d !== winner);
  return { winner, discarded };
}

/**
 * @param {Array<{ docId: string, data: object }>} docs
 * @returns {Array<{ type: string, newDocId: string, newData: object, toDelete: Array<string>, duplicateCount: number }>}
 */
function buildMigrationPlan(docs) {
  const { clean, duplicates } = classifyAssignments(docs);
  const plan = [];

  for (const doc of clean) {
    const newDocId = deterministicId(doc.data.itemId, doc.data.containerId);
    plan.push({
      type: 'rename',
      newDocId,
      newData: { ...doc.data, id: newDocId },
      toDelete: [doc.docId],
      duplicateCount: 1,
    });
  }

  for (const group of duplicates) {
    const newDocId = deterministicId(group[0].data.itemId, group[0].data.containerId);
    const { winner } = resolveWinner(group);
    plan.push({
      type: 'merge',
      newDocId,
      newData: { ...winner.data, id: newDocId },
      toDelete: group.map((d) => d.docId),
      duplicateCount: group.length,
    });
  }

  return plan;
}

module.exports = {
  deterministicId,
  isUuidId,
  groupByPair,
  classifyAssignments,
  resolveWinner,
  buildMigrationPlan,
};
