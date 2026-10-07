(function() {
  function initializeDistrictGallery() {
    document.querySelectorAll('input[data-district-gallery]').forEach(function(input) {
      if (input.dataset.galleryInitialized || typeof DataTransfer === 'undefined') return;
      input.dataset.galleryInitialized = 'true';
      var files = [];
      var list = document.createElement('ul');
      list.setAttribute('aria-live', 'polite');
      input.insertAdjacentElement('afterend', list);

      function renderSelection() {
        var transfer = new DataTransfer();
        list.replaceChildren();
        files.forEach(function(file, index) {
          transfer.items.add(file);
          var item = document.createElement('li');
          item.appendChild(document.createTextNode(file.name + ' '));
          var remove = document.createElement('button');
          remove.type = 'button';
          remove.textContent = 'Remove from selection';
          remove.setAttribute('aria-label', 'Remove ' + file.name + ' from selection');
          remove.addEventListener('click', function() {
            files.splice(index, 1);
            renderSelection();
          });
          item.appendChild(remove);
          list.appendChild(item);
        });
        input.files = transfer.files;
      }

      input.addEventListener('change', function() {
        Array.from(input.files || []).forEach(function(file) {
          if (!files.some(function(existing) {
            return existing.name === file.name && existing.size === file.size && existing.lastModified === file.lastModified;
          })) files.push(file);
        });
        renderSelection();
      });
    });
  }

  document.addEventListener('DOMContentLoaded', initializeDistrictGallery);
  document.addEventListener('turbolinks:load', initializeDistrictGallery);
  document.addEventListener('turbo:load', initializeDistrictGallery);
})();
