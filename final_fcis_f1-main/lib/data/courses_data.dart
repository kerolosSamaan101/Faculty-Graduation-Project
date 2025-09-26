class Course {
  final String name;
  final Map<String, String> lectures;
  final Map<String, String> labs;

  Course({required this.name, required this.lectures, required this.labs});
}

List<Course> courses = [
  Course(name: "OS", lectures: {
    'Lecture 1':
        'https://drive.google.com/drive/folders/1HYv-HTODHmOl3GCiDZJpWiyzh_oDheFT',
    'Lecture 2':
        'https://drive.google.com/drive/folders/1MOSLlBUs9DFFlx__R33HJhzA07UdRHoe',
    'Lecture 3':
        'https://drive.google.com/drive/folders/1U14ZhLEIJOkS54Xi7YGUFVolpxpR5UG0',
    'Lecture 4':
        'https://drive.google.com/drive/folders/1WZA28xz14t3RrYfXgtQ0OwKJ_gHdLKqQ',
    'Lecture 5':
        'https://drive.google.com/drive/folders/1W86oEjmMNIsm3y5z82t2wTVEWwMLlK0S',
    'Lecture 6':
        'https://drive.google.com/drive/folders/1_e6NfqbGBkCWDhn12smGuMKQqT2zIMpN',
    'Lecture 7':
        'https://drive.google.com/drive/folders/1HuPjYwlZnTV6lkyR8X8R1a7Y6wzBe2Wz',
    'Lecture 8':
        'https://drive.google.com/drive/folders/1iEjYOCoRL7vM31KbbjyWOJufTPoyOGzp',
    'Lecture 9':
        'https://drive.google.com/drive/folders/1nsk3mXafmApX7KSbdt5xY018Ta3HlHVH',
    'Lecture 10':
        'https://drive.google.com/drive/folders/1T99vtAUi2VlaRdISnOoV4ZNyqiGf05zG',
  }, labs: {
    'Lab 1':
        'https://drive.google.com/drive/folders/1MOSLlBUs9DFFlx__R33HJhzA07UdRHoe',
    'Lab 2':
        'https://drive.google.com/drive/folders/19IkLm0H_Sgdtx8YkYv74G9Q2oKjWngw3',
    'Lab 3':
        'https://drive.google.com/drive/folders/1i9x5udLFask63RsgSgo5nqvMQwCne_FY',
    'Lab 4':
        'https://drive.google.com/drive/folders/101rBZb1-nshLl24u33rHrXMR6uS6t5Yf',
    'Lab 6':
        'https://drive.google.com/drive/folders/1U73OtGziDgYjud0IYWtG_6Kcg3L78OFS',
    'Lab 7':
        'https://drive.google.com/drive/folders/1sSERTyrYrAzJQhamXGmLbaJWoWvfUwOL',
    'Lab 9':
        'https://drive.google.com/drive/folders/1K8mqZpY6MSdYN2EbcIzwtvIyPXPprPWV',
  }),
  Course(name: "Networks", lectures: {
    'Lecture 1':
        'https://docs.google.com/presentation/d/1j9CpyNCfxbH5v-nbtKVbwPsksxf61lvs/edit#slide=id.p1',
    'Lecture 2':
        'https://docs.google.com/presentation/d/1fIDlan1eGy_sR6M9ZpvdNB9xurL_nbiO/edit',
    'Lecture 3':
        'https://docs.google.com/presentation/d/1zhKr2KU6B0DI836NGg8zJYDm-Ar5uNLF/edit',
    'Lecture 4':
        'https://docs.google.com/presentation/d/1WFlfYgRL0dhF_UltKos-wtsHqkVEJ_Im/edit#slide=id.p1',
    'Lecture 5':
        'https://docs.google.com/presentation/d/1z-PryNtskZCMhNNEOxFxqCmVXsA175Mc/edit#slide=id.p1',
    'Lecture 6':
        'https://docs.google.com/presentation/d/1Xs_gyB1Lvp_eIoKsYXbXoCvgTdXNZE3b/edit',
    'Lecture 7':
        'https://docs.google.com/presentation/d/1zVxFpo6uVEIDVUaUhm--w4NcKCouAgFV/edit',
    'Lecture 8':
        'https://docs.google.com/presentation/d/15X2FOBtJaEhj-EiSH-HCAEzRKIjdc070/edit#slide=id.p1',
    'Lecture 9':
        'https://docs.google.com/presentation/d/1BkORMAWVNwZgR_zygkZJ5JFvJo9OlT72/edit#slide=id.p1',
    'Lecture 10':
        'https://docs.google.com/presentation/d/1ixvSd7Fiu16IAyzbhvUCsrKtMnL4YfOX/edit',
  }, labs: {
    'Lab 1':
        'https://drive.google.com/drive/folders/1MOSLlBUs9DFFlx__R33HJhzA07UdRHoe',
    'Lab 2':
        'https://drive.google.com/drive/folders/19IkLm0H_Sgdtx8YkYv74G9Q2oKjWngw3',
    'Lab 3':
        'https://drive.google.com/drive/folders/1i9x5udLFask63RsgSgo5nqvMQwCne_FY',
    'Lab 4':
        'https://drive.google.com/drive/folders/101rBZb1-nshLl24u33rHrXMR6uS6t5Yf',
    'Lab 6':
        'https://drive.google.com/drive/folders/1U73OtGziDgYjud0IYWtG_6Kcg3L78OFS',
    'Lab 7':
        'https://drive.google.com/drive/folders/1sSERTyrYrAzJQhamXGmLbaJWoWvfUwOL',
    'Lab 9':
        'https://drive.google.com/drive/folders/1K8mqZpY6MSdYN2EbcIzwtvIyPXPprPWV',
  }),
  Course(name: "SAAD", lectures: {
    'Lecture 1':
        'https://docs.google.com/presentation/d/1oMF3XkW_-gmsl16Hdl1hZChMODa1sz2T/edit#slide=id.p1',
    'Lecture 2':
        'https://docs.google.com/presentation/d/1p89sO1v9UUXG3PQHPqCDPUuVVenBEJ96/edit#slide=id.p1',
    'Lecture 3':
        'https://docs.google.com/presentation/d/1UlUdUqZ585BwcCAwz5ppvTDmtjLMAtpE/edit#slide=id.p1',
    'Lecture 4':
        'https://docs.google.com/presentation/d/1raDDTlIDrP86sH5258od-gvaSdY-3AcC/edit',
    'Lecture 5':
        'https://docs.google.com/presentation/d/1DOOIW1_ArmXW3ELWwd808jS0KWKcngzH/edit?rtpof=true',
    'Lecture 6':
        'https://docs.google.com/presentation/d/1NxUcG8fE6sPxXkt9jHHJEU8HHpzc97St/edit',
    'Lecture 7':
        'https://docs.google.com/presentation/d/1O1_prjZWsjsHoWqUpN7rzyQG5FPnwfnj/edit',
    'Lecture 8':
        'https://docs.google.com/presentation/d/1OB_ErU_XYoqR1VaHy2eyGDhDfB2dSmzA/edit?rtpof=true',
    'Lecture 9':
        'https://docs.google.com/presentation/d/1BkORMAWVNwZgR_zygkZJ5JFvJo9OlT72/edit#slide=id.p1',
    'Lecture 10':
        'https://docs.google.com/presentation/d/1sbeoCe8U7GzRqUsBe55qx8sggOR1AfQ9/edit',
  }, labs: {
    'Lab 1':
        'https://docs.google.com/presentation/d/1pDL6NKsRFHp2bPE-I2a5tEIIebzAHaml/edit#slide=id.p1',
    'Lab 2':
        'https://docs.google.com/presentation/d/12PcPXheclLpsJvyXgkjiYWoBnJQ3h8Po/edit',
    'Lab 3':
        'https://drive.google.com/drive/folders/1L-vSrF3g3vBIDMf7OU7d8QkpeEtPiUQa',
    'Lab 4':
        'https://docs.google.com/presentation/d/1LHA2zCN1BlBVUjNnukGzBfwnaZK2g_8y/edit',
    'Lab 5':
        'https://docs.google.com/presentation/d/1DQ1tBY5tthWZUyUKdkJiINKNPGz5E5Oj/edit',
    'Lab 6':
        'https://docs.google.com/presentation/d/1NztoAWTKOqdnE1R3LSlYk5QgyWM6R7sS/edit#slide=id.p1',
    'Lab 7':
        'https://docs.google.com/presentation/d/1O2eq88fPwoerLO-zUZICcc_Pjs1VqwZ4/edit',
    'Lab 8':
        'https://docs.google.com/presentation/d/1Msdp1Dg7LQ1lnRxIUxgNt6Eq-sdtngLF/edit',
    'Lab 9':
        'https://docs.google.com/presentation/d/1cjhfFFPNrcZFnvkPjSRYQwGW0ncDvj6l/edit#slide=id.p1',
  }),
  Course(name: "Algorithms", lectures: {
    'Lecture 1':
        'https://drive.google.com/drive/folders/1gbXrmmzLrgp06815soh-Kh7tksiDca70',
    'Lecture 2':
        'https://drive.google.com/drive/folders/1R5k7txcAf_qd54xIWwdf9ks85JVTqFZ6',
    'Lecture 3':
        'https://drive.google.com/drive/folders/1n6N_f_n8fwCgDXdMZqF0bIRPlUzq_O-O',
    'Lecture 4':
        'https://drive.google.com/drive/folders/1yCknRsH7dlGl-nLPnTg4OE8PNV_M99yM',
    'Lecture 5':
        'https://drive.google.com/drive/folders/1RD605q_hKOx7ual9sHHpTKaGbhtsYYn1',
    'Lecture 6':
        'https://drive.google.com/drive/folders/1U2cPniGgLZebbN98Ac-rCMUszMPra8eC',
    'Lecture 7':
        'https://drive.google.com/drive/folders/18bPst_gGP6-O56ahuuOwDkh6thXApvox',
    'Lecture 8':
        'https://drive.google.com/drive/folders/1vIjIdlbDLJusvBVCSyT9dJmiN4Mjt2f6',
    'Lecture 9':
        'https://drive.google.com/drive/folders/1FT45HcudDOXpqAeVCYFg7a5xSXSkRHQa',
    'Lecture 10':
        'https://drive.google.com/drive/folders/1ORIh0YT5FLa6LFw2R8JKGcHaeGRcGcLY',
    'Lecture 11':
        'https://drive.google.com/drive/folders/1nhmWQ1XKi65BnjLTds7-eE-6klR8DskV',
    'Lecture 12':
        'https://drive.google.com/drive/folders/1TirpbyCbbe0tCujEG6R1pQHkk4dyb2m1',
  }, labs: {
    'Lab 1':
        'https://drive.google.com/drive/folders/1kxKcOq534htmBQfyV0-teU9TZlRfSLcH',
    'Lab 2':
        'https://drive.google.com/drive/folders/1dt_ynzTbcsXg3GtrMmGfrBggNVZzZ4l8',
    'Lab 3':
        'https://drive.google.com/drive/folders/1mRzg2dONoc-BRzxx09gCG-UIqRWP8ZZc',
    'Lab 4':
        'https://drive.google.com/drive/folders/1-Vap4T3BqMdq-T65h80aYra66sOXpA9B',
    'Lab 5':
        'https://docs.google.com/presentation/d/1DQ1tBY5tthWZUyUKdkJiINKNPGz5E5Oj/edit',
    'Lab 6':
        'https://drive.google.com/drive/folders/1gZqB-aKdVQxgZ6wcUBCzTT_RS01hUM0q',
    'Lab 7':
        'https://drive.google.com/drive/folders/1koJT5kvSnPiUB2m7Gi5lNSG2C9CpaKQ9',
    'Lab 8':
        'https://drive.google.com/drive/folders/1DY8gyqEZF2UDDXhCWWvyY5dMZxOi0CY3',
    'Lab 9':
        'https://drive.google.com/drive/folders/1HMrh87wPOMH1a2iX6JDDeWVSgWdFYkRf',
  }),
  Course(name: "OS", lectures: {
    'Lecture 1':
        'https://drive.google.com/drive/folders/1HYv-HTODHmOl3GCiDZJpWiyzh_oDheFT',
    'Lecture 2':
        'https://drive.google.com/drive/folders/1MOSLlBUs9DFFlx__R33HJhzA07UdRHoe',
    'Lecture 3':
        'https://drive.google.com/drive/folders/1U14ZhLEIJOkS54Xi7YGUFVolpxpR5UG0',
    'Lecture 4':
        'https://drive.google.com/drive/folders/1WZA28xz14t3RrYfXgtQ0OwKJ_gHdLKqQ',
    'Lecture 5':
        'https://drive.google.com/drive/folders/1W86oEjmMNIsm3y5z82t2wTVEWwMLlK0S',
    'Lecture 6':
        'https://drive.google.com/drive/folders/1_e6NfqbGBkCWDhn12smGuMKQqT2zIMpN',
    'Lecture 7':
        'https://drive.google.com/drive/folders/1HuPjYwlZnTV6lkyR8X8R1a7Y6wzBe2Wz',
    'Lecture 8':
        'https://drive.google.com/drive/folders/1iEjYOCoRL7vM31KbbjyWOJufTPoyOGzp',
    'Lecture 9':
        'https://drive.google.com/drive/folders/1nsk3mXafmApX7KSbdt5xY018Ta3HlHVH',
    'Lecture 10':
        'https://drive.google.com/drive/folders/1T99vtAUi2VlaRdISnOoV4ZNyqiGf05zG',
  }, labs: {
    'Lab 1':
        'https://drive.google.com/drive/folders/1MOSLlBUs9DFFlx__R33HJhzA07UdRHoe',
    'Lab 2':
        'https://drive.google.com/drive/folders/19IkLm0H_Sgdtx8YkYv74G9Q2oKjWngw3',
    'Lab 3':
        'https://drive.google.com/drive/folders/1i9x5udLFask63RsgSgo5nqvMQwCne_FY',
    'Lab 4':
        'https://drive.google.com/drive/folders/101rBZb1-nshLl24u33rHrXMR6uS6t5Yf',
    'Lab 6':
        'https://drive.google.com/drive/folders/1U73OtGziDgYjud0IYWtG_6Kcg3L78OFS',
    'Lab 7':
        'https://drive.google.com/drive/folders/1sSERTyrYrAzJQhamXGmLbaJWoWvfUwOL',
    'Lab 9':
        'https://drive.google.com/drive/folders/1K8mqZpY6MSdYN2EbcIzwtvIyPXPprPWV',
  }),
  Course(name: "OS", lectures: {
    'Lecture 1':
        'https://drive.google.com/drive/folders/1HYv-HTODHmOl3GCiDZJpWiyzh_oDheFT',
    'Lecture 2':
        'https://drive.google.com/drive/folders/1MOSLlBUs9DFFlx__R33HJhzA07UdRHoe',
    'Lecture 3':
        'https://drive.google.com/drive/folders/1U14ZhLEIJOkS54Xi7YGUFVolpxpR5UG0',
    'Lecture 4':
        'https://drive.google.com/drive/folders/1WZA28xz14t3RrYfXgtQ0OwKJ_gHdLKqQ',
    'Lecture 5':
        'https://drive.google.com/drive/folders/1W86oEjmMNIsm3y5z82t2wTVEWwMLlK0S',
    'Lecture 6':
        'https://drive.google.com/drive/folders/1_e6NfqbGBkCWDhn12smGuMKQqT2zIMpN',
    'Lecture 7':
        'https://drive.google.com/drive/folders/1HuPjYwlZnTV6lkyR8X8R1a7Y6wzBe2Wz',
    'Lecture 8':
        'https://drive.google.com/drive/folders/1iEjYOCoRL7vM31KbbjyWOJufTPoyOGzp',
    'Lecture 9':
        'https://drive.google.com/drive/folders/1nsk3mXafmApX7KSbdt5xY018Ta3HlHVH',
    'Lecture 10':
        'https://drive.google.com/drive/folders/1T99vtAUi2VlaRdISnOoV4ZNyqiGf05zG',
  }, labs: {
    'Lab 1':
        'https://drive.google.com/drive/folders/1MOSLlBUs9DFFlx__R33HJhzA07UdRHoe',
    'Lab 2':
        'https://drive.google.com/drive/folders/19IkLm0H_Sgdtx8YkYv74G9Q2oKjWngw3',
    'Lab 3':
        'https://drive.google.com/drive/folders/1i9x5udLFask63RsgSgo5nqvMQwCne_FY',
    'Lab 4':
        'https://drive.google.com/drive/folders/101rBZb1-nshLl24u33rHrXMR6uS6t5Yf',
    'Lab 6':
        'https://drive.google.com/drive/folders/1U73OtGziDgYjud0IYWtG_6Kcg3L78OFS',
    'Lab 7':
        'https://drive.google.com/drive/folders/1sSERTyrYrAzJQhamXGmLbaJWoWvfUwOL',
    'Lab 9':
        'https://drive.google.com/drive/folders/1K8mqZpY6MSdYN2EbcIzwtvIyPXPprPWV',
  }),
  Course(name: "OS", lectures: {
    'Lecture 1':
        'https://drive.google.com/drive/folders/1HYv-HTODHmOl3GCiDZJpWiyzh_oDheFT',
    'Lecture 2':
        'https://drive.google.com/drive/folders/1MOSLlBUs9DFFlx__R33HJhzA07UdRHoe',
    'Lecture 3':
        'https://drive.google.com/drive/folders/1U14ZhLEIJOkS54Xi7YGUFVolpxpR5UG0',
    'Lecture 4':
        'https://drive.google.com/drive/folders/1WZA28xz14t3RrYfXgtQ0OwKJ_gHdLKqQ',
    'Lecture 5':
        'https://drive.google.com/drive/folders/1W86oEjmMNIsm3y5z82t2wTVEWwMLlK0S',
    'Lecture 6':
        'https://drive.google.com/drive/folders/1_e6NfqbGBkCWDhn12smGuMKQqT2zIMpN',
    'Lecture 7':
        'https://drive.google.com/drive/folders/1HuPjYwlZnTV6lkyR8X8R1a7Y6wzBe2Wz',
    'Lecture 8':
        'https://drive.google.com/drive/folders/1iEjYOCoRL7vM31KbbjyWOJufTPoyOGzp',
    'Lecture 9':
        'https://drive.google.com/drive/folders/1nsk3mXafmApX7KSbdt5xY018Ta3HlHVH',
    'Lecture 10':
        'https://drive.google.com/drive/folders/1T99vtAUi2VlaRdISnOoV4ZNyqiGf05zG',
  }, labs: {
    'Lab 1':
        'https://drive.google.com/drive/folders/1MOSLlBUs9DFFlx__R33HJhzA07UdRHoe',
    'Lab 2':
        'https://drive.google.com/drive/folders/19IkLm0H_Sgdtx8YkYv74G9Q2oKjWngw3',
    'Lab 3':
        'https://drive.google.com/drive/folders/1i9x5udLFask63RsgSgo5nqvMQwCne_FY',
    'Lab 4':
        'https://drive.google.com/drive/folders/101rBZb1-nshLl24u33rHrXMR6uS6t5Yf',
    'Lab 6':
        'https://drive.google.com/drive/folders/1U73OtGziDgYjud0IYWtG_6Kcg3L78OFS',
    'Lab 7':
        'https://drive.google.com/drive/folders/1sSERTyrYrAzJQhamXGmLbaJWoWvfUwOL',
    'Lab 9':
        'https://drive.google.com/drive/folders/1K8mqZpY6MSdYN2EbcIzwtvIyPXPprPWV',
  }),
  Course(name: "OS", lectures: {
    'Lecture 1':
        'https://drive.google.com/drive/folders/1HYv-HTODHmOl3GCiDZJpWiyzh_oDheFT',
    'Lecture 2':
        'https://drive.google.com/drive/folders/1MOSLlBUs9DFFlx__R33HJhzA07UdRHoe',
    'Lecture 3':
        'https://drive.google.com/drive/folders/1U14ZhLEIJOkS54Xi7YGUFVolpxpR5UG0',
    'Lecture 4':
        'https://drive.google.com/drive/folders/1WZA28xz14t3RrYfXgtQ0OwKJ_gHdLKqQ',
    'Lecture 5':
        'https://drive.google.com/drive/folders/1W86oEjmMNIsm3y5z82t2wTVEWwMLlK0S',
    'Lecture 6':
        'https://drive.google.com/drive/folders/1_e6NfqbGBkCWDhn12smGuMKQqT2zIMpN',
    'Lecture 7':
        'https://drive.google.com/drive/folders/1HuPjYwlZnTV6lkyR8X8R1a7Y6wzBe2Wz',
    'Lecture 8':
        'https://drive.google.com/drive/folders/1iEjYOCoRL7vM31KbbjyWOJufTPoyOGzp',
    'Lecture 9':
        'https://drive.google.com/drive/folders/1nsk3mXafmApX7KSbdt5xY018Ta3HlHVH',
    'Lecture 10':
        'https://drive.google.com/drive/folders/1T99vtAUi2VlaRdISnOoV4ZNyqiGf05zG',
  }, labs: {
    'Lab 1':
        'https://drive.google.com/drive/folders/1MOSLlBUs9DFFlx__R33HJhzA07UdRHoe',
    'Lab 2':
        'https://drive.google.com/drive/folders/19IkLm0H_Sgdtx8YkYv74G9Q2oKjWngw3',
    'Lab 3':
        'https://drive.google.com/drive/folders/1i9x5udLFask63RsgSgo5nqvMQwCne_FY',
    'Lab 4':
        'https://drive.google.com/drive/folders/101rBZb1-nshLl24u33rHrXMR6uS6t5Yf',
    'Lab 6':
        'https://drive.google.com/drive/folders/1U73OtGziDgYjud0IYWtG_6Kcg3L78OFS',
    'Lab 7':
        'https://drive.google.com/drive/folders/1sSERTyrYrAzJQhamXGmLbaJWoWvfUwOL',
    'Lab 9':
        'https://drive.google.com/drive/folders/1K8mqZpY6MSdYN2EbcIzwtvIyPXPprPWV',
  }),
];

class NonAcademicTrack {
  final String name;
  final Map<String, Map<String, String>> levels;

  NonAcademicTrack({required this.name, required this.levels});
}

List<NonAcademicTrack> csTracks = [
  NonAcademicTrack(
    name: 'Machine Learning & Deep Learning',
    levels: {
      'Beginner': {
        'Python for Beginners':
            'https://www.youtube.com/watch?v=QXeEoD0pB3E&list=PLsyeobzWxl7poL9JTVyndKe62ieoN-MZ3',
        'Probability and Statistics':
            'https://www.youtube.com/watch?v=GmJJ2iZz08c&list=PLxIvc-MGOs6gW9SgkmoxE5w9vQkID1_r-',
        'Linear Algebra':
            'https://www.youtube.com/watch?v=1RnKXrJwseo&list=PLxIvc-MGOs6iQXFnjF_STbhGdrZBphrv_'
      },
      'Intermediate': {
        'Overview Artificial Intelligence Course | Stanford CS221':
            'https://www.youtube.com/watch?v=J8Eh7RqggsU&list=PLoROMvodv4rO1NB9TD4iUZ3qghGEGtqNX',
        'Machine Learning with Python':
            'https://www.freecodecamp.org/learn/machine-learning-with-python/',
        'Stanford CS230: Deep Learning':
            'https://www.youtube.com/watch?v=PySo_6S4ZAg&list=PLoROMvodv4rOABXSygHTsbvUz4G_YQhOb',
      },
      'Advanced': {
        'Machine Learning with Python Certification':
            'https://www.freecodecamp.org/learn/machine-learning-with-python/',
        'TINTOlib: Deep Learning en Tidy Data con Imágenes sintéticas':
            'https://www.udemy.com/course/tintolib-deep-learning-tabutar-data-con-imagenes-sinteticas/',
        'APDS: Intro to Advanced Python for MLOps and Data Science':
            'https://www.udemy.com/course/apds-intro-to-advanced-python-for-mlops-and-data-science/',
      },
    },
  ),
  NonAcademicTrack(
    name: 'Flutter',
    levels: {
      'Beginner': {
        'OOP in Java':
            'https://www.youtube.com/watch?v=FaaM6uVbuJM&list=PLCInYL3l2AagY7fFlhCrjpLiIFybW3yQv',
        ' Object Oriented Programming With Java':
            'https://www.youtube.com/watch?v=M3Na5luSx50&list=PL1DUmTEdeA6Icttz-O9C3RPRF8R8Px5vk',
        'Learning Dart [in arabic]':
            'https://www.youtube.com/watch?v=kgN7veo9tC0&list=PL93xoMrxRJIsYc9L0XBSaiiuq01JTMQ_o',
      },
      'Intermediate': {
        '( 2023 - 2024) learn flutter from zero to hero':
            'https://www.youtube.com/watch?v=kgN7veo9tC0&list=PL93xoMrxRJIsYc9L0XBSaiiuq01JTMQ_o',
        'Flutter sqflite':
            'https://www.youtube.com/watch?v=JCtpzjgye0g&list=PLuETFhVfu9Hd-78U9UasTZYWFSxxnnPM4',
        'علم التعامل مع قواعد البيانات Sql - mysql - course - من الصفر الى الاحتراف  - learn - tutorial - شرح - تعلم - كورس':
            'https://www.youtube.com/playlist?list=PL93xoMrxRJIuicqcd1UpFUYMfWKGp7JmI',
        'Flutter Provider State Management Course':
            'https://www.youtube.com/playlist?list=PLFyjjoCMAPtzn7tFLRV3eny7G74LnlMRt',
        'learn GetX from zero to hero':
            'https://www.youtube.com/playlist?list=PL93xoMrxRJIvZHL420f63bWIOrcoM6NU-',
      },
      'Advanced': {
        'Mastering Firebase With Flutter ( 2023 )':
            'https://www.youtube.com/playlist?list=PL93xoMrxRJIvZHL420f63bWIOrcoM6NU-',
        'Rest Api With PHP And Flutter':
            'https://www.youtube.com/playlist?list=PL93xoMrxRJItcqJJgyCpA7Wv_YL-ii6Dl',
        'Appzio on-boarding':
            'https://www.udemy.com/course/appzio-on-boarding/',
        '(2023) MVC مشروع المتجر الالكتروني باستخدام فلاتر':
            'https://www.udemy.com/course/appzio-on-boarding/',
      },
    },
  ),
  NonAcademicTrack(name: 'Software Testing', levels: {
    'Beginner': {
      'ISTQB foundation level':
          'https://www.youtube.com/watch?v=XXRJp9IIr_s&list=PL594OqWI4Um7Uk6utSPMBoMqTd7odsSr_',
      'ISTQB AGILE TESTER FOUNDATION 2025':
          'https://www.youtube.com/watch?v=xAt6ihVLYl8&list=PLj5VKaW115t1FBcIc3meLd59ee-d3QNWJ',
      'Become Software Tester - A Complete Learning path to be a QA':
          'https://www.udemy.com/course/become-software-tester/',
      'Agile Scrum Fundamentals for Product Managers':
          'https://www.udemy.com/course/agile-scrum-fundamentals-for-product-managers/',
    },
    'Intermediate': {
      'Software Construction and Release':
          'https://www.udemy.com/course/software-construction-and-release/',
      'Mocking application with Moq':
          'https://www.udemy.com/course/moq-framework/',
      'Software Testing By Innovation Techniques':
          'https://www.udemy.com/course/software-testing-by-innovation-techniques/',
      'ATDD البرمجة الموجهة بالاختبارات المقبولة':
          'https://www.udemy.com/course/atdd-cs-ar/',
      'Spring Boot Testing Masterclass: JUnit, Mockito, and More':
          'https://www.udemy.com/course/spring-boot-testing-masterclass-junit-mockito-and-more/',
    },
    'Advanced': {
      'Introduction to Unit Testing':
          'https://www.udemy.com/course/refactoru-intro-unit-test/',
      'Sauce Labs Masterclass: Advanced Test Automation':
          'https://www.udemy.com/course/sauce-labs/',
    }
  }),
  NonAcademicTrack(name: "Game Development", levels: {
    'Beginner': {
      'Welcome to Game Theory':
          'https://www.coursera.org/learn/game-theory-introduction',
      'C# tutorial for beginners':
          'https://www.coursera.org/learn/game-theory-introduction',
      'Game Development in C++ with SFML':
          'https://www.youtube.com/watch?v=esGMreLmed0&list=PLs6oRBoE2-Q_fX_rzraQekRoL7Kr7s5xi',
    },
    'Intermediate': {
      'UPValenciaX: Introduction to video game development with Unity':
          'https://www.edx.org/learn/game-development/universitat-politecnica-de-valencia-introduction-to-video-game-development-with-unity?irclickid=T%3A5Ue02VqxycRepQNRzE-UFKUksRk8xkJ2Xj2U0&utm_source=affiliate&utm_medium=Class%20Central&utm_campaign=Harvard%27s%20Computer%20Science%20for%20Python%20Programming_&utm_content=TEXT_LINK&irgwc=1',
      'How to make a 2D Game in Unity':
          'https://www.youtube.com/watch?v=on9nwbZngyw&list=PLPV2KyIb3jR6TFcFuzI2bB7TMNIIBpKMQ&pp=0gcJCV8EOCosWNin',
      'Learn Unity 3D for Absolute Beginners':
          'https://www.udemy.com/course/learnunity3d/?ranMID=39197&ranEAID=SAyYsTvLiGQ&ranSiteID=SAyYsTvLiGQ-qU1JgMu0Pqx.tkAOtIs6DQ&LSNPUBID=SAyYsTvLiGQ&utm_source=aff-campaign&utm_medium=udemyads',
    },
    'Advanced': {
      'Advanced Game Development and Unity Basics (Paid)':
          'https://www.coursera.org/learn/packt-advanced-game-development-and-unity-basics-vrxyj',
      'Game Theory II: Advanced Applications ':
          'https://www.coursera.org/learn/game-theory-2',
      'Unity Advanced Tutorials':
          'https://youtube.com/playlist?list=PLPV2KyIb3jR5qEyOlJImGFoHcxg9XUQci&si=Q1eB-b2KByEsCFuT',
      'Games in Scratch #4: Elevator (Project)':
          'https://www.udemy.com/course/games-in-scratch-4-elevator/',
    }
  }),
  NonAcademicTrack(name: 'Cyber Security', levels: {
    'Beginner': {
      'Cyber Security for beginners':
          'https://www.youtube.com/watch?v=lpa8uy4DyMo&list=PL9ooVrP1hQOGPQVeapGsJCktzIO4DtI4_',
      'Introduction to cyber security':
          'https://www.netacad.com/courses/introduction-to-cybersecurity?courseLang=en-US',
      "HarvardX: CS50's Introduction to Cybersecurity":
          'https://www.edx.org/learn/cybersecurity/harvard-university-cs50-s-introduction-to-cybersecurity?irclickid=T%3A5Ue02VqxycRepQNRzE-UFKUksRkaWYJ2Xj2U0&utm_source=affiliate&utm_medium=Class%20Central&utm_campaign=Harvard%27s%20Computer%20Science%20for%20Python%20Programming_&utm_content=TEXT_LINK&irgwc=1',
    },
    'Intermediate': {
      'Network Security':
          'https://www.classcentral.com/course/network-security-183956',
      'Secure Software Development Lifecycle (SSDLC)':
          'https://maharatech.gov.eg/course/view.php?id=2117',
      'Ethical Hacking': 'https://maharatech.gov.eg/course/view.php?id=870',
    },
    'Advanced': {
      'nformation Security Certification':
          'https://www.freecodecamp.org/learn/information-security/',
      'CISSP Domain 1 Practice Questions':
          'https://www.udemy.com/course/wannapractice-cissp-domain-1-practice-questions/',
      'IBM Cybersecurity Analyst Professional Certificate Assessmen (paid)':
          'https://www.udemy.com/course/ibm-cybersecurity-analyst-professional-certificate-assessmen/?couponCode=KEEPLEARNING',
      'AI & Cybersecurity: Threats, Global Actors, and Trends-2025 (paid)':
          'https://www.udemy.com/course/ai-cybersecurity-threats-global-actors-and-trends-2025/?couponCode=KEEPLEARNING',
    }
  }),
];
