require 'active_record/associations/collection_proxy'

class ActiveRecord::Associations::CollectionProxy

  # I cannot find any other way to tell an association object to actually unload
  # the records it caches. - Jared
  def unload
    reset
    @association.reset
    self
  end

end
