import { Component, OnInit } from '@angular/core';
import { faArrowRight, faShoppingBag } from '@fortawesome/free-solid-svg-icons';
import { Notification, NotificationService } from '../services/notification.service';

@Component({
  selector: 'app-notifications',
  templateUrl: './notifications.component.html',
  styleUrls: ['./notifications.component.scss']
})
export class NotificationsComponent implements OnInit {

  notifications:Notification[] = [];

  faShoppingBag = faShoppingBag
  faArrowRight = faArrowRight;

  constructor(
    private notificationService: NotificationService
  ) 
  { 
    notificationService.getNotifications().subscribe({
      next: data => {
        this.notifications = [...data];
      }
    })
  }

  ngOnInit(): void {
  }

}
