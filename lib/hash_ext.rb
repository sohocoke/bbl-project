class Hash
  # produce a new hash that cascades other hashes -- combines another hash with me, with other values taking priority.
  def cascaded(*hashes)
    cascaded = self.dup
    
    hashes.each do |hash|
      hash.each do |k, v|
        if v.is_a? Hash
          # recur.
          val_to_insert = (cascaded[k] || {}).combine(v)
        else
          # insert value from hash in result.
          val_to_insert = v
        end

        if val_to_insert
          cascaded[k] = val_to_insert
        end
      end

    end

    cascaded
  end
end