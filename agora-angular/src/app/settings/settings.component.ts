import { Component, OnInit } from '@angular/core';
import { faAddressCard, faBell, faEnvelope, faHeart, faMapMarkerAlt, faTrash } from '@fortawesome/free-solid-svg-icons';

@Component({
  selector: 'app-settings',
  templateUrl: './settings.component.html',
  styleUrls: ['./settings.component.scss']
})
export class SettingsComponent implements OnInit {

  faAddressCard = faAddressCard;
  faMapMarker = faMapMarkerAlt;
  faBell = faBell;
  faHeart = faHeart;
  faTrash = faTrash;
  faEnvelope = faEnvelope;

  constructor() { }

  ngOnInit(): void {
  }

}
