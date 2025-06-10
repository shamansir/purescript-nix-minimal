import generateUniqueId from 'generate-unique-id';

function _genMyId() {
  return generateUniqueId();
}

export const generate_ = _genMyId;
