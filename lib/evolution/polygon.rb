module Evolution
  class Polygon
    
    attr_accessor :points, :red, :green, :blue, :alpha
    
    def initialize(other = nil)
      @points = []
      
      if other
        other.points.each { |point| self.points << point }
        [:red, :green, :blue, :alpha].each{ |method| send("#{method}=", other.send(method)) }
      else
        3.times { add_point }
        [:red=, :green=, :blue=, :alpha=].each{ |method| send(method, rand(256)) }
      end
    end
    
    def mutate
      mutate_rgba   if rand(Evolution::RGBA_MUTATION_RATE)       == 0
      mutate_points if rand(Evolution::POINT_MUTATION_RATE)      == 0
      add_point     if rand(Evolution::ADD_POINT_MUTATION_RATE)  == 0
    end
    
    def to_svg
      fill = "#" + red.to_hex + green.to_hex + blue.to_hex
      fill_opacity = alpha / 256.0
      points_string = points.map{ |point| point.join(',') }.join(' ')
      "\t<polygon fill=\"#{fill}\" fill-opacity=\"#{fill_opacity}\" points=\"#{points_string}\" />"
    end
    
    def fill_string
      "#" + red.to_hex + green.to_hex + blue.to_hex + alpha.to_hex
    end
    
    
    private
    
    def mutate_rgba
      [:red, :green, :blue, :alpha].each do |attribute|
        mutated_value = Evolution.generate_mutation(:min => 0, :max => 255, :initial => send(attribute))
        send("#{attribute}=", mutated_value)
      end
    end
    
    def mutate_points
      points.each_with_index do |point, i|
        mutated_values = point.map { |value| Evolution.generate_mutation(:max => Evolution::CANVAS_SIZE, :initial => value) }
        points[i] = mutated_values
      end
    end
    
    def add_point
      if points.empty?
        @points << [rand(Evolution::CANVAS_SIZE), rand(Evolution::CANVAS_SIZE)]
      elsif points.size == 1
        x = Evolution.generate_mutation(:initial => points[0][0], :min => 0, :max => Evolution::CANVAS_SIZE - 1)
        y = Evolution.generate_mutation(:initial => points[0][1], :min => 0, :max => Evolution::CANVAS_SIZE - 1)
        @points << [x, y]
      else
        point_a = points[rand(points.size)]
        index = points.index(point_a)
        point_b = points[(index + 1) % points.size]
        x = Evolution.generate_mutation( :initial => (point_a[0] + point_b[0]) / 2,
                                         :min => 0,
                                         :max => Evolution::CANVAS_SIZE - 1 )
        y = Evolution.generate_mutation( :initial => (point_a[1] + point_b[1]) / 2,
                                         :min => 0,
                                         :max => Evolution::CANVAS_SIZE - 1 )
        @points.insert(index + 1, [x, y])
      end
    end
    
  end
end