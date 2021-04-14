Rails.application.routes.draw do
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :tasks do
    collection {post :import}
  end
  
  resources :users do
    collection {post :import}
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      patch 'update_user_info'
      get 'attendance_log'
      get 'confirm_one_month' 
      #モーダル月次確認遷移
      get 'attendances/edit_one_month' 
      #勤怠編集画面
      patch 'attendances/update_one_month' 
      #勤怠編集画面保存
      get 'attendances/notice_monthly' 
      #月次所属長承認申請のお知らせ
      patch 'attendances/approval_monthly' 
      #月次所属長承認申請ﾓｰﾀﾞﾙ変更送信
    end
    
    resources :attendances, only: :update do
      member do
        get 'edit_overwork_request' 
        #残業申請
        patch 'update_overwork_request' 
        #残業申請変更送信
        get 'notice_overwork_request' 
        #残業申請のお知らせ
        patch 'approval_overwork_request' 
        #残業申請のお知らせﾓｰﾀﾞﾙ変更送信
        patch 'update_monthly' 
        #所属長承認申請  
        get 'notice_one_month' 
        #勤怠編集変更申請のお知らせ
        patch 'approval_one_month' 
        #勤怠編集変更申請ﾓｰﾀﾞﾙ変更送信
  
      end
    end
  end
end