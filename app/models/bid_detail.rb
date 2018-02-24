class BidDetail < ApplicationRecord
	after_commit :create_digital_contract, :on => [:update] 
	def create_digital_contract
		total_votes_cast = 0
		approval_weight = 0.0

		bid_details = self.bid.bid_details

		bid_details.each do |bid_detail|
			if(bid_detail.has_voted == true)
				total_votes_cast += 1
				approval_weight += bid_detail.approval_percentage
			else
				break
			end
		end

		project_title = self.bid.project.title
		if(total_votes_cast == bid_details.count && approval_weight > 50.0)
			project_leader_id = self.bid.project.leader_id
			notification_leader = Notification.new(user_id: project_leader_id, 
												   notification_type_id: 1,
												   notification_description: getDescription(1, true, self.bid.user.email, project_title))
			notification_leader.save
			notification_user = Notification.new(user_id: self.bid.user_id, 
												   notification_type_id: 1,
												   notification_description: getDescription(1, false, self.bid.user.email, project_title))
			notification_user.save
			DigitalContract.new(bid_id: self.bid.bid_id, project_id: self.bid.project.id)
			DigitalContract.save
		end
		if(total_votes_cast == bid_details.count && approval_weight <= 50.0)
			notification_leader = Notification.new(user_id: project_leader_id, 
												   notification_type_id: 1,
												   notification_description: getDescription(5, true, self.bid.user.email,project_title))
			notification_leader.save
			notification_user = Notification.new(user_id: self.bid.user_id, 
												   notification_type_id: 1,
												   notification_description: getDescription(5, false, self.bid.user.email ,project_title))
			notification_user.save
		end
	end
end
